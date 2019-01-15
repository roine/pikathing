module Page.Template.Add exposing (Model, Msg(..), getKey, init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, button, div, input, label, li, text, ul)
import Html.Attributes exposing (class, disabled, id, value)
import Html.Events exposing (onClick, onInput)
import Random
import Route
import Task
import Template exposing (Template(..), TodoListTemplate, TodoTemplate)
import Uuid.Barebones



-- MODEL


type alias Model =
    { key : Nav.Key
    , name : String
    , id : String
    , nextTodoId : String
    , todos : Dict String TodoTemplate
    , transient : TodoListTemplate
    }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key
      , name = ""
      , id = ""
      , todos = Dict.fromList []
      , transient = { name = "" }
      , nextTodoId = ""
      }
    , Cmd.batch
        [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
        , Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator
        ]
    )



-- UPDATE


type Msg
    = UpdateName String
    | UpdateTransientName String
    | Add
    | Save
    | NewUIDForTodoList String
    | NewUIDForTodo String
    | NoOp


update : Msg -> Template -> Model -> ( Template, Model, Cmd Msg )
update msg ((Template todoListTemplates todoTemplates) as templates) model =
    let
        transient =
            model.transient
    in
    case msg of
        UpdateName newName ->
            ( templates, { model | name = newName }, Cmd.none )

        UpdateTransientName newTodoName ->
            ( templates, { model | transient = { transient | name = newTodoName } }, Cmd.none )

        Add ->
            ( templates
            , { model
                | todos = Dict.insert model.nextTodoId { name = model.transient.name, templateId = model.id } model.todos
                , transient = { transient | name = "" }
              }
            , Cmd.batch [ Task.attempt (always NoOp) (Dom.focus "todo-input"), Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator ]
            )

        Save ->
            ( Template (Dict.insert model.id { name = model.name } todoListTemplates) (Dict.union todoTemplates model.todos)
            , model
            , Nav.pushUrl model.key (Route.toString Route.Home)
            )

        NoOp ->
            ( templates, model, Cmd.none )

        NewUIDForTodoList newUuid ->
            ( templates, { model | id = newUuid }, Cmd.none )

        NewUIDForTodo newUuid ->
            ( templates, { model | nextTodoId = newUuid }, Cmd.none )



-- VIEW


view : Model -> Template -> Html Msg
view model template =
    let
        meetPrerequisite =
            not (String.isEmpty model.name) && not (Dict.isEmpty model.todos)
    in
    div []
        [ div [ class "form-group" ]
            [ label [] [ text "Template name" ]
            , input
                [ value model.name
                , class "form-control"
                , onInput UpdateName
                ]
                []
            ]
        , div [ class "from-group" ]
            [ label [] [ text "Todo" ]
            , input
                [ value model.transient.name
                , class "form-control"
                , onInput UpdateTransientName
                , id "todo-input"
                ]
                []
            , button [ onClick Add ] [ text "Add Todo" ]
            , ul []
                (List.map
                    (\todo ->
                        li [] [ text todo.name ]
                    )
                    (Dict.values model.todos)
                )
            ]
        , button [ onClick Save, disabled (not meetPrerequisite) ] [ text "Save" ]
        , text (Debug.toString template)
        , text (Debug.toString model)
        ]


getKey : Model -> Nav.Key
getKey =
    .key