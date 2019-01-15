module Page.Template.Edit exposing (Model, Msg, getKey, init, update, view)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (div, text)
import Template exposing (Template(..), TodoListTemplate, TodoTemplate, getTodoByTemplateId)


type alias Model =
    { key : Nav.Key
    , name : String
    , todoTemplates : Dict String TodoTemplate
    }


init key (Template todolistTemplates todoTemplates) id =
    let
        todoListTemplate =
            Dict.get id todolistTemplates

        todoTemplate =
            getTodoByTemplateId id todoTemplates
    in
    ( { key = key
      , name =
            case todoListTemplate of
                Nothing ->
                    ""

                Just m ->
                    m.name
      , todoTemplates = todoTemplate
      }
    , Cmd.none
    )


type Msg
    = NoOp


update msg template model =
    ( template, model, Cmd.none )


view model template =
    div [] [ text "" ]


getKey =
    .key
