module ActualList exposing (ActualList(..), Todo, TodoList, decoder, encoder, init)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode


type ActualList
    = ActualList (Dict String TodoList) (Dict String Todo)


type alias TodoList =
    { templateId : String, name : String, notes : String }


type alias Todo =
    { templateId : String --todolist where the tod0 belong
    , completed : Bool
    , todoId : String -- tod0 template
    }


init =
    ActualList Dict.empty Dict.empty


encoder : ActualList -> Json.Encode.Value
encoder (ActualList todolist todo) =
    Json.Encode.object
        [ ( "todoList"
          , Json.Encode.dict identity
                (\{ name, templateId, notes } ->
                    Json.Encode.object
                        [ ( "templateId", Json.Encode.string templateId )
                        , ( "name", Json.Encode.string name )
                        , ( "notes", Json.Encode.string notes )
                        ]
                )
                todolist
          )
        , ( "todo"
          , Json.Encode.dict identity
                (\{ templateId, completed, todoId } ->
                    Json.Encode.object
                        [ ( "templateId", Json.Encode.string templateId )
                        , ( "completed", Json.Encode.bool completed )
                        , ( "todoId", Json.Encode.string todoId )
                        ]
                )
                todo
          )
        ]


decoder : Json.Decode.Decoder ActualList
decoder =
    Json.Decode.map2 ActualList
        (Json.Decode.field "todoList"
            (Json.Decode.dict
                (Json.Decode.map3 TodoList
                    (Json.Decode.field "templateId" Json.Decode.string)
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.field "notes" Json.Decode.string)
                )
            )
        )
        (Json.Decode.field "todo"
            (Json.Decode.dict
                (Json.Decode.map3 Todo
                    (Json.Decode.field "templateId" Json.Decode.string)
                    (Json.Decode.field "completed" Json.Decode.bool)
                    (Json.Decode.field "todoId" Json.Decode.string)
                )
            )
        )
