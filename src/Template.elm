module Template exposing (Template(..), TodoListTemplate, TodoTemplate, buildTodoList, decoder, encoder, getTodoByTemplateId, init)

import Color exposing (Color)
import Dict exposing (Dict)
import Icon exposing (Icon)
import Json.Decode
import Json.Encode


init =
    Template Dict.empty Dict.empty


type Template
    = Template (Dict String TodoListTemplate) (Dict String TodoTemplate)


type alias TodoListTemplate =
    { name : String, icon : Maybe Icon, colour : Color }


buildTodoList : { a | name : String, icon : Maybe Icon, colour : Color } -> TodoListTemplate
buildTodoList model =
    { name = model.name, icon = model.icon, colour = model.colour }


type alias TodoTemplate =
    { name : String, templateId : String }


initialTodoTemplate : TodoTemplate
initialTodoTemplate =
    { name = "", templateId = "" }


getTodoByTemplateId : String -> Dict String { a | templateId : String } -> Dict String { a | templateId : String }
getTodoByTemplateId id todoTemplates =
    Dict.filter (\_ value -> id == value.templateId) todoTemplates


encoder : Template -> Json.Encode.Value
encoder (Template todolistTemplates todoTemplates) =
    let
        withIcon maybeIcon =
            case maybeIcon of
                Nothing ->
                    []

                Just icon ->
                    [ ( "icon", Json.Encode.string (Icon.toString icon) ) ]
    in
    Json.Encode.object
        [ ( "todoListTemplates"
          , Json.Encode.dict identity
                (\{ name, icon, colour } ->
                    Json.Encode.object
                        ([ ( "name", Json.Encode.string name )
                         , ( "colour"
                           , Json.Encode.object
                                [ ( "red", Json.Encode.float (.red (Color.toRgba colour)) )
                                , ( "green", Json.Encode.float (.green (Color.toRgba colour)) )
                                , ( "blue", Json.Encode.float (.blue (Color.toRgba colour)) )
                                , ( "alpha", Json.Encode.float (.alpha (Color.toRgba colour)) )
                                ]
                           )
                         ]
                            ++ withIcon icon
                        )
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
                (Json.Decode.map3 TodoListTemplate
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.maybe (Json.Decode.field "icon" Json.Decode.string) |> Json.Decode.map (Maybe.andThen Icon.fromString))
                    (Json.Decode.field "colour"
                        (Json.Decode.map4
                            Color.rgba
                            (Json.Decode.field "red" Json.Decode.float)
                            (Json.Decode.field "green" Json.Decode.float)
                            (Json.Decode.field "blue" Json.Decode.float)
                            (Json.Decode.field "alpha" Json.Decode.float)
                        )
                    )
                )
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
