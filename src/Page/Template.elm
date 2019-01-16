module Page.Template exposing (Model(..), Msg(..), decoder, encoder, getKey, init, update, view)

import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Page.Template.Add as TemplateAdd
import Page.Template.Edit as TemplateEdit
import Route
import Template exposing (Template(..))


type Model
    = AddModel TemplateAdd.Model
    | EditModel TemplateEdit.Model


init : Nav.Key -> Template -> Route.SubTemplatePage -> ( Model, Cmd Msg )
init key template route =
    case route of
        Route.AddPage ->
            TemplateAdd.init key
                |> Tuple.mapBoth AddModel (Cmd.map AddMsg)

        Route.EditPage id ->
            TemplateEdit.init key template id
                |> Tuple.mapBoth EditModel (Cmd.map EditMsg)



-- UPDATE


type Msg
    = AddMsg TemplateAdd.Msg
    | EditMsg TemplateEdit.Msg


update : Msg -> Template -> Model -> ( Template, Model, Cmd Msg )
update msg template model =
    case ( msg, model ) of
        ( AddMsg subMsg, AddModel m ) ->
            let
                ( newTemplate, newModel, cmd ) =
                    TemplateAdd.update subMsg template m
            in
            ( newTemplate, AddModel newModel, Cmd.map AddMsg cmd )

        ( EditMsg subMsg, EditModel m ) ->
            let
                ( newTemplate, newModel, cmd ) =
                    TemplateEdit.update subMsg template m
            in
            ( newTemplate, EditModel newModel, Cmd.map EditMsg cmd )

        _ ->
            ( template, model, Cmd.none )



-- VIEW


view : Model -> Template -> Html Msg
view model template =
    case model of
        AddModel m ->
            Html.map AddMsg (TemplateAdd.view m template)

        EditModel m ->
            Html.map EditMsg (TemplateEdit.view m template)



-- MISC


getKey : Model -> Nav.Key
getKey model =
    case model of
        AddModel m ->
            TemplateAdd.getKey m

        EditModel m ->
            TemplateEdit.getKey m


encoder : Model -> Template -> Json.Encode.Value
encoder model template =
    case model of
        AddModel addModel ->
            Json.Encode.object
                [ ( "type", Json.Encode.string "Template" )
                , ( "subType", Json.Encode.string "Add" )
                , ( "model", TemplateAdd.encoder addModel )
                , ( "template", Template.encoder template )
                ]

        EditModel editModel ->
            Json.Encode.object
                [ ( "type", Json.Encode.string "Template" )
                , ( "subType", Json.Encode.string "Edit" )
                , ( "model", TemplateEdit.encoder editModel )
                , ( "template", Template.encoder template )
                ]


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

                    _ ->
                        Json.Decode.fail ""
            )
