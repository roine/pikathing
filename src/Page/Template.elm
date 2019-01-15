module Page.Template exposing (Model(..), Msg(..), getKey, init, update, view)

import Browser.Navigation as Nav
import Html
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
