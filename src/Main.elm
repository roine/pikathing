port module Main exposing (Flags, Model(..), Msg(..), bodyView, getKey, init, main, navView, subscriptions, toRoute, update, view)

import ActualList exposing (ActualList(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (class, href)
import Json.Decode
import Json.Encode
import Page.Home
import Page.Template exposing (Model(..), Msg(..))
import Route
import Template exposing (Template(..))
import Url


port save : String -> Cmd msg


type Model
    = HomePage Page.Home.Model Template ActualList
    | TemplatePage Page.Template.Model Template ActualList
    | NotFoundPage { key : Nav.Key } Template ActualList
    | ErrorPage Json.Decode.Error Nav.Key Template ActualList


type alias Flags =
    Maybe String


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init saved url key =
    case saved of
        Just encodedModel ->
            case decoded key encodedModel of
                Ok model ->
                    ( model, Cmd.none )

                Err err ->
                    ( ErrorPage err key Template.init ActualList.init, Cmd.none )

        Nothing ->
            toRoute url key Template.init ActualList.init


toRoute : Url.Url -> Nav.Key -> Template -> ActualList -> ( Model, Cmd Msg )
toRoute url key template actualList =
    case Route.fromUrl url of
        Nothing ->
            ( NotFoundPage { key = key } template actualList, Cmd.none )

        Just Route.Home ->
            let
                ( homeModel, cmd ) =
                    Page.Home.init key
            in
            ( HomePage homeModel template actualList
            , Cmd.batch
                [ Cmd.map HomeMsg cmd
                , save (encoded (Page.Home.encoder template actualList homeModel))
                ]
            )

        Just (Route.Template subRoute) ->
            let
                ( templateModel, cmd ) =
                    Page.Template.init key template subRoute
            in
            ( TemplatePage templateModel template actualList
            , Cmd.batch
                [ Cmd.map TemplateMsg cmd
                , save (encoded (Page.Template.encoder template actualList templateModel))
                ]
            )



-- UPDATE


getTemplateFromModel : Model -> Template
getTemplateFromModel model =
    case model of
        HomePage _ template _ ->
            template

        TemplatePage _ template _ ->
            template

        NotFoundPage _ template _ ->
            template

        ErrorPage error key template _ ->
            template


getActualListFromModel model =
    case model of
        HomePage _ _ actualList ->
            actualList

        TemplatePage _ _ actualList ->
            actualList

        NotFoundPage _ _ actualList ->
            actualList

        ErrorPage error key _ actualList ->
            actualList


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChange Url.Url
    | HomeMsg Page.Home.Msg
    | TemplateMsg Page.Template.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update" ( msg, model ) of
        ( UrlRequested urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (getKey model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChange url, _ ) ->
            toRoute url (getKey model) (getTemplateFromModel model) (getActualListFromModel model)

        ( HomeMsg subMsg, HomePage home template actualList ) ->
            let
                ( newModel, cmd ) =
                    Page.Home.update subMsg home
            in
            ( HomePage newModel template actualList
            , Cmd.batch [ Cmd.map HomeMsg cmd, save (encoded (Page.Home.encoder template actualList newModel)) ]
            )

        ( TemplateMsg subMsg, TemplatePage m t actualList ) ->
            let
                updated =
                    Page.Template.update subMsg t actualList m
            in
            ( TemplatePage updated.model updated.template updated.actualList
            , Cmd.batch
                [ Cmd.map TemplateMsg updated.cmd
                , save (encoded (Page.Template.encoder updated.template actualList updated.model))
                ]
            )

        ( _, _ ) ->
            ( model, Cmd.none )


getKey : Model -> Nav.Key
getKey model =
    case model of
        HomePage m _ _ ->
            Page.Home.getKey m

        NotFoundPage m _ _ ->
            m.key

        TemplatePage m _ _ ->
            Page.Template.getKey m

        ErrorPage error key template _ ->
            key



-- VIEW


view : Model -> Document Msg
view model =
    { title =
        case model of
            HomePage _ _ _ ->
                "Homepage"

            TemplatePage _ _ _ ->
                "Template"

            NotFoundPage _ _ _ ->
                "Not Found"

            ErrorPage _ _ _ _ ->
                ""
    , body =
        [ navView model
        , bodyView model
        ]
    }


navView : Model -> Html Msg
navView model =
    ul []
        [ li [] [ a [ href (Route.toString Route.Home) ] [ text "Home page" ] ]
        , li [] [ a [ href (Route.toString (Route.Template Route.AddPage)) ] [ text "Create a template" ] ]
        ]


bodyView : Model -> Html Msg
bodyView model =
    div [ class "container" ]
        [ case model of
            HomePage m t tl ->
                Html.map HomeMsg (Page.Home.view t tl m)

            TemplatePage m t tl ->
                Html.map TemplateMsg (Page.Template.view t tl m)

            NotFoundPage _ _ _ ->
                text "Page not found"

            ErrorPage error _ template _ ->
                text (Json.Decode.errorToString error)
        , div []
            [ text (Debug.toString model)
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- INIT


decoded key payload =
    Json.Decode.decodeString (decoder key) payload


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\type_ ->
                case type_ of
                    "Home" ->
                        Json.Decode.map3 HomePage
                            (Page.Home.decoder key)
                            (Json.Decode.field "template" Template.decoder)
                            (Json.Decode.field "todoList" ActualList.decoder)

                    "Template" ->
                        Json.Decode.map3 TemplatePage
                            (Page.Template.decoder key)
                            (Json.Decode.field "template" Template.decoder)
                            (Json.Decode.field "todoList" ActualList.decoder)

                    _ ->
                        Json.Decode.fail "Unknown type"
            )


encoded =
    Json.Encode.encode 0


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChange
        }
