module Page.Template exposing (Model(..), Msg(..), decoder, encoder, getKey, init, subscritptions, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Page.Template.Add as TemplateAdd
import Page.Template.Edit as TemplateEdit
import Page.Template.View as TemplateView
import Route
import Template exposing (Template(..))


type Model
    = AddModel TemplateAdd.Model
    | EditModel TemplateEdit.Model
    | ViewModel TemplateView.Model


init : Nav.Key -> Template -> Route.CrudPage -> ( Model, Cmd Msg )
init key template route =
    case route of
        Route.AddPage ->
            TemplateAdd.init key
                |> Tuple.mapBoth AddModel (Cmd.map AddMsg)

        Route.EditPage id ->
            TemplateEdit.init key template id
                |> Tuple.mapBoth EditModel (Cmd.map EditMsg)

        Route.ViewPage id ->
            TemplateView.init key id template
                |> Tuple.mapBoth ViewModel (Cmd.map ViewMsg)



-- UPDATE


type Msg
    = AddMsg TemplateAdd.Msg
    | EditMsg TemplateEdit.Msg
    | ViewMsg TemplateView.Msg


update : Msg -> Template -> ActualList -> Model -> { template : Template, actualList : ActualList, model : Model, cmd : Cmd Msg }
update msg template actualList model =
    case ( msg, model ) of
        ( AddMsg subMsg, AddModel m ) ->
            let
                ( newTemplate, newModel, cmd ) =
                    TemplateAdd.update subMsg template m
            in
            { template = newTemplate, actualList = actualList, model = AddModel newModel, cmd = Cmd.map AddMsg cmd }

        ( EditMsg subMsg, EditModel m ) ->
            let
                updated =
                    TemplateEdit.update subMsg template actualList m
            in
            { template = updated.templates, actualList = updated.actualLists, model = EditModel updated.model, cmd = Cmd.map EditMsg updated.cmd }

        ( ViewMsg subMsg, ViewModel m ) ->
            let
                ( newActualList, newModel, cmd ) =
                    TemplateView.update subMsg template actualList m
            in
            { template = template, actualList = newActualList, model = ViewModel newModel, cmd = Cmd.map ViewMsg cmd }

        _ ->
            { template = template, actualList = actualList, model = model, cmd = Cmd.none }



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view template actualList model =
    case model of
        AddModel m ->
            Html.map AddMsg (TemplateAdd.view template actualList m)

        EditModel m ->
            Html.map EditMsg (TemplateEdit.view template actualList m)

        ViewModel m ->
            Html.map ViewMsg (TemplateView.view template actualList m)



-- MISC


subscritptions : Template -> ActualList -> Model -> Sub Msg
subscritptions template actualList model =
    case model of
        AddModel m ->
            Sub.none

        EditModel m ->
            Sub.map EditMsg (TemplateEdit.subscriptions template actualList m)

        ViewModel m ->
            Sub.none


getKey : Model -> Nav.Key
getKey model =
    case model of
        AddModel m ->
            TemplateAdd.getKey m

        EditModel m ->
            TemplateEdit.getKey m

        ViewModel m ->
            TemplateView.getKey m


encoder : Template -> ActualList -> Model -> Json.Encode.Value
encoder template actualList model =
    let
        sharedEncoder =
            [ ( "type", Json.Encode.string "Template" )
            , ( "template", Template.encoder template )
            , ( "todoList", ActualList.encoder actualList )
            ]
    in
    case model of
        AddModel addModel ->
            sharedEncoder
                |> (++)
                    [ ( "subType", Json.Encode.string "Add" )
                    , ( "model", TemplateAdd.encoder addModel )
                    ]
                |> Json.Encode.object

        EditModel editModel ->
            sharedEncoder
                |> (++)
                    [ ( "subType", Json.Encode.string "Edit" )
                    , ( "model", TemplateEdit.encoder editModel )
                    ]
                |> Json.Encode.object

        ViewModel viewModel ->
            sharedEncoder
                |> (++)
                    [ ( "subType", Json.Encode.string "View" )
                    , ( "model", TemplateView.encoder viewModel )
                    ]
                |> Json.Encode.object


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "subType" Json.Decode.string
        |> Json.Decode.andThen
            (\type_ ->
                case type_ of
                    "Add" ->
                        Json.Decode.map AddModel (Json.Decode.field "model" (TemplateAdd.decoder key))

                    "Edit" ->
                        Json.Decode.map EditModel (Json.Decode.field "model" (TemplateEdit.decoder key))

                    "View" ->
                        Json.Decode.map ViewModel (Json.Decode.field "model" (TemplateView.decoder key))

                    otherwise ->
                        Json.Decode.fail ("Tried decoding " ++ otherwise)
            )
