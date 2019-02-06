port module Main exposing (Flags, Model(..), Msg(..), bodyView, getKey, init, main, subscriptions, toRoute, update, view)

--import Debug.Extra

import ActualList exposing (ActualList(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, code, div, h1, li, p, pre, text, ul)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode exposing (Value)
import Page.Compare
import Page.Home
import Page.Template exposing (Model(..), Msg(..))
import Page.TodoList
import Route exposing (Page(..))
import Task
import Template exposing (Template(..))
import Url


port save : String -> Cmd msg


port export_ : () -> Cmd msg


type Model
    = HomePage Page.Home.Model Template ActualList
    | TemplatePage Page.Template.Model Template ActualList
    | TodoListPage Page.TodoList.Model Template ActualList
    | NotFoundPage { key : Nav.Key } Template ActualList
    | ComparePage Page.Compare.Model Template ActualList
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

        Just (Route.TodoList subRoute) ->
            let
                ( todoListModel, cmd ) =
                    Page.TodoList.init key template subRoute
            in
            ( TodoListPage todoListModel template actualList
            , Cmd.batch
                [ Cmd.map TodoListMsg cmd
                , save (encoded (Page.TodoList.encoder template actualList todoListModel))
                ]
            )

        Just (Compare id1 id2) ->
            let
                ( compareModel, cmd ) =
                    Page.Compare.init id1 id2 key
            in
            ( ComparePage compareModel template actualList
            , Cmd.batch
                [ Cmd.map CompareMsg cmd
                , save (encoded (Page.Compare.encoder template actualList compareModel))
                ]
            )



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChange Url.Url
    | HomeMsg Page.Home.Msg
    | TemplateMsg Page.Template.Msg
    | TodoListMsg Page.TodoList.Msg
    | CompareMsg Page.Compare.Msg
    | Export
    | Loaded File
    | Import
    | ExtractFileContent String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        noOp =
            ( model, Cmd.none )
    in
    case ( msg, model ) of
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

        ( HomeMsg subMsg, _ ) ->
            noOp

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

        ( TemplateMsg subMsg, _ ) ->
            noOp

        ( TodoListMsg subMsg, TodoListPage m t actualList ) ->
            let
                updated =
                    Page.TodoList.update subMsg t actualList m
            in
            ( TodoListPage updated.model updated.template updated.actualList
            , Cmd.batch
                [ Cmd.map TodoListMsg updated.cmd
                , save (encoded (Page.TodoList.encoder updated.template updated.actualList updated.model))
                ]
            )

        ( TodoListMsg subMsg, _ ) ->
            noOp

        ( CompareMsg subMsg, ComparePage m t actualList ) ->
            let
                ( newModel, cmd ) =
                    Page.Compare.update subMsg m
            in
            ( ComparePage newModel t actualList
            , Cmd.batch
                [ Cmd.map CompareMsg cmd
                , save (encoded (Page.Compare.encoder t actualList newModel))
                ]
            )

        ( CompareMsg subMsg, _ ) ->
            noOp

        ( Export, _ ) ->
            ( model, export_ () )

        ( Import, _ ) ->
            ( model, Select.file [ "application/json" ] Loaded )

        ( Loaded file, _ ) ->
            ( model, Task.perform ExtractFileContent (File.toString file) )

        ( ExtractFileContent data, _ ) ->
            case decoded (getKey model) data of
                Ok newModel ->
                    ( newModel, Cmd.none )

                Err err ->
                    ( ErrorPage err (getKey model) Template.init ActualList.init, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title =
        case model of
            HomePage _ _ _ ->
                "Homepage"

            TemplatePage _ _ _ ->
                "Template"

            TodoListPage _ _ _ ->
                "Todo list"

            ComparePage _ _ _ ->
                "Comparing"

            NotFoundPage _ _ _ ->
                "Not Found"

            ErrorPage _ _ _ _ ->
                ""
    , body =
        [ navView model
        , bodyView model
        , case model of
            ErrorPage _ _ _ _ ->
                text ""

            NotFoundPage _ _ _ ->
                text ""

            _ ->
                text ""

        --                div [ class "container" ] [ Debug.Extra.viewModel model ]
        ]
    }


navView : Model -> Html Msg
navView model =
    div [ class "bg-primary p-3 mb-3" ]
        [ div [ class "container text-center" ]
            [ h1 [] [ a [ class "text-light", href (Route.toString Route.Home) ] [ text "Plume" ] ]
            ]
        ]


bodyView : Model -> Html Msg
bodyView model =
    div [ class "container" ]
        [ case model of
            HomePage m t tl ->
                Html.map HomeMsg (Page.Home.view t tl m)

            TemplatePage m t tl ->
                Html.map TemplateMsg (Page.Template.view t tl m)

            TodoListPage m t tl ->
                Html.map TodoListMsg (Page.TodoList.view t tl m)

            ComparePage m t tl ->
                Html.map CompareMsg (Page.Compare.view t tl m)

            NotFoundPage _ _ _ ->
                text "Page not found"

            ErrorPage error _ template _ ->
                text (Json.Decode.errorToString error)
        , div [ class "btn-group" ]
            [ button [ class "btn btn-primary", onClick Import ] [ text "Import" ]
            , button [ class "btn btn-secondary", onClick Export ] [ text "Export" ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        HomePage m template actualList ->
            Sub.map HomeMsg (Page.Home.subscriptions template actualList m)

        TemplatePage m template actualList ->
            Sub.map TemplateMsg (Page.Template.subscriptions template actualList m)

        TodoListPage m template actualList ->
            Sub.map TemplateMsg (Page.TodoList.subscriptions template actualList m)

        NotFoundPage record template actualList ->
            Sub.none

        ErrorPage error key template actualList ->
            Sub.none

        ComparePage m template actualList ->
            Sub.none


decoded : Nav.Key -> String -> Result Json.Decode.Error Model
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

                    "TodoList" ->
                        Json.Decode.map3 TodoListPage
                            (Page.TodoList.decoder key)
                            (Json.Decode.field "template" Template.decoder)
                            (Json.Decode.field "todoList" ActualList.decoder)

                    "Compare" ->
                        Json.Decode.map3 ComparePage
                            (Page.Compare.decoder key)
                            (Json.Decode.field "template" Template.decoder)
                            (Json.Decode.field "todoList" ActualList.decoder)

                    unknownType ->
                        Json.Decode.fail ("Unknown type " ++ unknownType)
            )


encoded : Value -> String
encoded =
    Json.Encode.encode 0


getKey : Model -> Nav.Key
getKey model =
    case model of
        HomePage m _ _ ->
            Page.Home.getKey m

        NotFoundPage m _ _ ->
            m.key

        TemplatePage m _ _ ->
            Page.Template.getKey m

        TodoListPage m _ _ ->
            Page.TodoList.getKey m

        ErrorPage error key template _ ->
            key

        ComparePage m _ _ ->
            Page.Compare.getKey m


getTemplateFromModel : Model -> Template
getTemplateFromModel model =
    case model of
        HomePage _ template _ ->
            template

        TemplatePage _ template _ ->
            template

        TodoListPage _ template _ ->
            template

        NotFoundPage _ template _ ->
            template

        ErrorPage error key template _ ->
            template

        ComparePage _ template _ ->
            template


getActualListFromModel : Model -> ActualList
getActualListFromModel model =
    case model of
        HomePage _ _ actualList ->
            actualList

        TemplatePage _ _ actualList ->
            actualList

        TodoListPage _ _ actualList ->
            actualList

        NotFoundPage _ _ actualList ->
            actualList

        ErrorPage error key _ actualList ->
            actualList

        ComparePage _ _ actualList ->
            actualList



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
