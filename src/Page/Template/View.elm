module Page.Template.View exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h2, i, input, label, li, text, ul)
import Html.Attributes exposing (class, href, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Json.Encode
import Random
import Route
import Template exposing (Template(..), TodoTemplate, getTodoByTemplateId)
import Uuid.Barebones


type alias Model =
    { key : Nav.Key
    , templateId : String
    , name : String
    , id : String
    , nextTodoIds : List String
    }



-- Count how many todos assign to this template


todoCount : String -> Dict String TodoTemplate -> Int
todoCount templateId todoTemplate =
    getTodoByTemplateId templateId todoTemplate
        |> Dict.size


init : Nav.Key -> String -> Template -> ( Model, Cmd Msg )
init key templateId (Template _ todoTemplate) =
    ( { key = key, templateId = templateId, name = "", id = "", nextTodoIds = [] }
    , Cmd.batch
        [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
        , Random.generate NewUIDForTodo (Random.list (todoCount templateId todoTemplate) Uuid.Barebones.uuidStringGenerator)
        ]
    )


type Msg
    = UpdateName String
    | MakeCopy
    | NewUIDForTodoList String
    | NewUIDForTodo (List String)


update : Msg -> Template -> ActualList -> Model -> ( ActualList, Model, Cmd Msg )
update msg (Template _ todoTemplate) ((ActualList todoLists todos) as actualList) model =
    case msg of
        UpdateName newName ->
            ( actualList, { model | name = newName }, Cmd.none )

        MakeCopy ->
            let
                newTodoList =
                    Dict.fromList [ ( model.id, { templateId = model.templateId, name = model.name } ) ]

                newTodos =
                    List.map2
                        (\( todoId, todo ) id ->
                            ( id
                            , { templateId = model.id
                              , completed = False
                              , todoId = todoId
                              }
                            )
                        )
                        (Dict.toList (getTodoByTemplateId model.templateId todoTemplate))
                        model.nextTodoIds
                        |> Dict.fromList
            in
            ( ActualList (Dict.union newTodoList todoLists) (Dict.union newTodos todos)
            , { model | name = "" }
            , Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
            )

        NewUIDForTodoList uid ->
            ( actualList, { model | id = uid }, Cmd.none )

        NewUIDForTodo uids ->
            ( actualList, { model | nextTodoIds = uids }, Cmd.none )


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates _) (ActualList todoLists todos) model =
    let
        currentTodoLists =
            getTodoByTemplateId model.templateId todoLists

        todoListTemplateName =
            Dict.get model.templateId todoListTemplates |> Maybe.map .name |> Maybe.withDefault ""
    in
    div []
        [ div [ class "row align-items-center" ]
            [ h2 [ class "col-auto pr-1" ]
                [ text todoListTemplateName
                ]
            , div [ class "col-auto pl-1" ]
                [ a [ href (Route.toString (Route.Template (Route.EditPage model.id))), class "badge badge-primary" ]
                    [ i [ class "fa fa-pencil-alt" ] []
                    ]
                ]
            ]
        , div [ class "form-row" ]
            [ div [ class "col-auto " ]
                [ label [ class "sr-only" ] [ text "Name" ]
                , input [ onInput UpdateName, value model.name, class "form-control", placeholder "Name of the copy, eg: Porsche" ] []
                ]
            , div [ class "col-auto" ] [ button [ onClick MakeCopy, class "btn btn-primary" ] [ text "Make a new copy" ] ]
            ]
        , ul []
            (List.map
                (\( id, todoList ) ->
                    li []
                        [ text todoList.name
                        , a [ href (Route.toString (Route.TodoList (Route.ViewPage id))), class "badge badge-primary" ]
                            [ i [ class "fa fa-pencil-alt" ] []
                            ]
                        ]
                )
                (Dict.toList currentTodoLists)
            )
        ]


encoder : Model -> Json.Encode.Value
encoder model =
    Json.Encode.object
        [ ( "templateId", Json.Encode.string model.templateId )
        , ( "name", Json.Encode.string model.name )
        , ( "id", Json.Encode.string model.id )
        , ( "nextTodoIds", Json.Encode.list Json.Encode.string model.nextTodoIds )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map5 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "templateId" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "nextTodoIds" (Json.Decode.list Json.Decode.string))


getKey : Model -> Nav.Key
getKey =
    .key
