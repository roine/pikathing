module Page.TodoList.View exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, a, button, div, h1, h2, i, input, label, li, span, text, textarea, ul)
import Html.Attributes exposing (checked, class, classList, href, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Icon
import Json.Decode
import Json.Encode
import Route
import Template exposing (Template(..), getTodoByTemplateId)



-- MODEL


type alias Model =
    { key : Nav.Key, id : String }


init key id template =
    ( { key = key, id = id }, Cmd.none )



-- UPDATE


type Msg
    = Toggle String Bool
    | Delete
    | UpdateNotes String


update : Msg -> Template -> ActualList -> Model -> ( ActualList, Model, Cmd Msg )
update msg template (ActualList todoLists todos) model =
    case msg of
        Toggle key checked ->
            ( ActualList todoLists
                (Dict.update key
                    (\maybeTodo ->
                        Maybe.map (\todo -> { todo | completed = checked }) maybeTodo
                    )
                    todos
                )
            , model
            , Cmd.none
            )

        Delete ->
            let
                newTodoLists =
                    Dict.remove model.id todoLists

                newTodos =
                    Dict.diff todos (getTodoByTemplateId model.id todos)
            in
            ( ActualList newTodoLists newTodos, model, Nav.back model.key 1 )

        UpdateNotes string ->
            ( ActualList
                (Dict.update
                    model.id
                    (\maybeTodoList -> Maybe.map (\todoList -> { todoList | notes = string }) maybeTodoList)
                    todoLists
                )
                todos
            , model
            , Cmd.none
            )



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates todoTemplates) (ActualList todoLists todos) { id } =
    let
        allData =
            Dict.get id todoLists
                |> Maybe.map
                    (\{ name, templateId, notes } ->
                        { name = name
                        , templateId = templateId
                        , templateName = Maybe.map .name (Dict.get templateId todoListTemplates) |> Maybe.withDefault ""
                        , todos =
                            getTodoByTemplateId id todos
                                |> Dict.map
                                    (\id_ { completed, todoId } ->
                                        { name = Dict.get todoId todoTemplates |> Maybe.map .name |> Maybe.withDefault ""
                                        , completed = completed
                                        }
                                    )
                        , notes = notes
                        }
                    )
    in
    div []
        (case allData of
            Nothing ->
                [ text "list not found" ]

            Just list ->
                [ h2 []
                    [ span [ class "mr-2" ]
                        [ a [ href (Route.toString (Route.Template (Route.ViewPage list.templateId))) ]
                            [ text list.templateName ]
                        ]
                    , span [] [ text ">" ]
                    , span [ class "ml-2" ] [ text list.name ]
                    ]
                , ul [ class "list-unstyled todo-list" ]
                    (List.map
                        (\( id_, todo ) ->
                            li [ class "todo-list__item", classList [ ( "todo-list__item--checked", todo.completed ) ] ]
                                [ label [ class "m-0 d-block todo-list__item__actionable" ]
                                    [ span [ class "mr-2" ]
                                        [ i
                                            [ class "far"
                                            , classList
                                                [ ( "fa-square", not todo.completed )
                                                , ( "fa-check-square", todo.completed )
                                                ]
                                            ]
                                            []
                                        ]
                                    , span []
                                        [ input [ type_ "checkbox", class "mr-2 d-none", checked todo.completed, onCheck (Toggle id_) ] []
                                        ]
                                    , span [] [ text todo.name ]
                                    ]
                                ]
                        )
                        (Dict.toList list.todos)
                    )
                , textarea [ value list.notes, class "form-control", onInput UpdateNotes ] []
                , button [ class "btn btn-danger", onClick Delete ] [ Icon.view [] Icon.Trash ]
                ]
        )



-- MISC


getKey : Model -> Nav.Key
getKey =
    .key


encoder : Model -> Json.Encode.Value
encoder model =
    Json.Encode.object [ ( "id", Json.Encode.string model.id ) ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map2 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "id" Json.Decode.string)
