module Page.Template.Edit exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Json.Decode
import Json.Encode
import Template exposing (Template(..), TodoListTemplate, TodoTemplate, getTodoByTemplateId)


type alias Model =
    { key : Nav.Key
    , name : String
    , todoTemplates : Dict String TodoTemplate
    }


init : Nav.Key -> Template -> String -> ( Model, Cmd Msg )
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


update : Msg -> Template -> Model -> ( Template, Model, Cmd Msg )
update msg template model =
    ( template, model, Cmd.none )


view : Model -> Template -> Html Msg
view model template =
    div [] [ text "" ]


getKey : Model -> Nav.Key
getKey =
    .key


encoder : Model -> Json.Encode.Value
encoder model =
    Json.Encode.object
        [ ( "name", Json.Encode.string model.name )
        , ( "todoTemplates"
          , Json.Encode.dict identity
                (\{ name, templateId } ->
                    Json.Encode.object [ ( "name", Json.Encode.string name ), ( "templateId", Json.Encode.string templateId ) ]
                )
                model.todoTemplates
          )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map3 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "todos"
            (Json.Decode.dict
                (Json.Decode.map2 TodoTemplate
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.field "templateId" Json.Decode.string)
                )
            )
        )
