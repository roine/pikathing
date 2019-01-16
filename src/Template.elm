module Template exposing (Template(..), TodoListTemplate, TodoTemplate, decoder, encoder, getTodoByTemplateId, init)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode


init =
    Template Dict.empty Dict.empty


type Template
    = Template (Dict String TodoListTemplate) (Dict String TodoTemplate)


type alias TodoListTemplate =
    { name : String }


initialTodoListTemplate : TodoListTemplate
initialTodoListTemplate =
    { name = "" }


type alias TodoTemplate =
    { name : String, templateId : String }


initialTodoTemplate : TodoTemplate
initialTodoTemplate =
    { name = "", templateId = "" }


getTodoByTemplateId : String -> Dict String TodoTemplate -> Dict String TodoTemplate
getTodoByTemplateId id todoTemplates =
    Dict.filter (\_ value -> id == value.templateId) todoTemplates


encoder : Template -> Json.Encode.Value
encoder (Template todolistTemplates todoTemplates) =
    Json.Encode.object
        [ ( "todoListTemplates"
          , Json.Encode.dict identity
                (\{ name } ->
                    Json.Encode.object [ ( "name", Json.Encode.string name ) ]
                )
                todolistTemplates
          )
        , ( "todoTemplates"
          , Json.Encode.dict identity
                (\{ name, templateId } ->
                    Json.Encode.object [ ( "name", Json.Encode.string name ), ( "templateId", Json.Encode.string templateId ) ]
                )
                todoTemplates
          )
        ]


decoder : Json.Decode.Decoder Template
decoder =
    Json.Decode.map2 Template
        (Json.Decode.field "todoListTemplates"
            (Json.Decode.dict
                (Json.Decode.map TodoListTemplate (Json.Decode.field "name" Json.Decode.string))
            )
        )
        (Json.Decode.field "todoTemplates"
            (Json.Decode.dict
                (Json.Decode.map2 TodoTemplate
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.field "templateId" Json.Decode.string)
                )
            )
        )
