port module Main exposing (Flags, Model(..), Msg(..), bodyView, getKey, init, main, navView, subscriptions, toRoute, update, view)

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
    = HomePage Page.Home.Model Template
    | TemplatePage Page.Template.Model Template
    | NotFoundPage { key : Nav.Key } Template


type alias Flags =
    Maybe String


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init saved url key =
    let
        decoder =
            Json.Decode.field "type" Json.Decode.string
                |> Json.Decode.andThen
                    (\type_ ->
                        case type_ of
                            "Home" ->
                                Json.Decode.map2 HomePage (Page.Home.decoder key) (Json.Decode.succeed Template.init)

                            _ ->
                                Json.Decode.fail "Unknown type"
                    )

        decoded payload =
            Json.Decode.decodeString decoder payload
    in
    case saved of
        Just encodedModel ->
            case decoded encodedModel of
                Ok model ->
                    ( model, Cmd.none )

                Err _ ->
                    toRoute url key Template.init

        Nothing ->
            toRoute url key Template.init


toRoute : Url.Url -> Nav.Key -> Template -> ( Model, Cmd Msg )
toRoute url key template =
    case Route.fromUrl url of
        Nothing ->
            ( NotFoundPage { key = key } template, Cmd.none )

        Just Route.Home ->
            let
                ( homeModel, cmd ) =
                    Page.Home.init key
            in
            ( HomePage homeModel template, Cmd.map HomeMsg cmd )

        Just (Route.Template subRoute) ->
            let
                ( templateAddModel, cmd ) =
                    Page.Template.init key template subRoute
            in
            ( TemplatePage templateAddModel template, Cmd.map TemplateMsg cmd )



-- UPDATE


getTemplateFromModel : Model -> Template
getTemplateFromModel model =
    case model of
        HomePage _ template ->
            template

        TemplatePage _ template ->
            template

        NotFoundPage _ template ->
            template


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChange Url.Url
    | HomeMsg Page.Home.Msg
    | TemplateMsg Page.Template.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UrlRequested urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (getKey model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChange url, _ ) ->
            toRoute url (getKey model) (getTemplateFromModel model)

        ( HomeMsg subMsg, HomePage home template ) ->
            let
                ( newModel, cmd ) =
                    Page.Home.update subMsg home
            in
            ( HomePage newModel template, Cmd.batch [ Cmd.map HomeMsg cmd, save (Json.Encode.encode 0 (Page.Home.encoder newModel template)) ] )

        ( TemplateMsg subMsg, TemplatePage m t ) ->
            let
                ( newTemplate, newModel, cmd ) =
                    Page.Template.update subMsg t m
            in
            ( TemplatePage newModel newTemplate, Cmd.map TemplateMsg cmd )

        ( _, _ ) ->
            ( model, Cmd.none )


getKey : Model -> Nav.Key
getKey model =
    case model of
        HomePage m _ ->
            Page.Home.getKey m

        NotFoundPage m _ ->
            m.key

        TemplatePage m _ ->
            Page.Template.getKey m



-- VIEW


view : Model -> Document Msg
view model =
    { title =
        case model of
            HomePage _ _ ->
                "Homepage"

            TemplatePage _ _ ->
                "Template"

            NotFoundPage _ _ ->
                "Not Found"
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
            HomePage m t ->
                Html.map HomeMsg (Page.Home.view m t)

            TemplatePage m t ->
                Html.map TemplateMsg (Page.Template.view m t)

            NotFoundPage _ _ ->
                text "Page not found"
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- INIT


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
