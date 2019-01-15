module Page.Template exposing (Model(..), Msg(..), getKey, update, view)

import Browser.Navigation as Nav
import Html exposing (text)
import Page.Template.Add as TemplateAdd


type Model
    = AddModel TemplateAdd.Model


getKey : Model -> Nav.Key
getKey model =
    case model of
        AddModel m ->
            m.key


type Msg
    = AddMsg TemplateAdd.Msg


update msg model =
    case ( msg, model ) of
        ( AddMsg subMsg, AddModel m ) ->
            let
                ( newModel, cmd ) =
                    TemplateAdd.update subMsg m
            in
            ( AddModel newModel, Cmd.map AddMsg cmd )


view model template =
    case model of
        AddModel m ->
            Html.map AddMsg (TemplateAdd.view m template)
