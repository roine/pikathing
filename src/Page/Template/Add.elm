module Page.Template.Add exposing (Model, Msg(..), getKey, init, update, view)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Html, button, div, input, label, li, text, ul)
import Html.Attributes exposing (class, disabled, id, value)
import Html.Events exposing (onClick, onInput)
import Route
import Task
import Template



-- MODEL


type alias Model =
    { key : Nav.Key
    , name : String
    , todos : List Todo
    , nextId : Int
    , transient : { name : String }
    }


type alias Todo =
    { id : Int, name : String }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key
      , name = ""
      , todos = [ { id = 1, name = "Color" } ]
      , nextId = 2
      , transient = { name = "" }
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdateName String
    | UpdateTransientName String
    | Add
    | Save
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        transient =
            model.transient
    in
    case msg of
        UpdateName newName ->
            ( { model | name = newName }, Cmd.none )

        UpdateTransientName newTodoName ->
            ( { model | transient = { transient | name = newTodoName } }, Cmd.none )

        Add ->
            ( { model
                | todos = { id = model.nextId, name = model.transient.name } :: model.todos
                , nextId = model.nextId + 1
                , transient = { transient | name = "" }
              }
            , Task.attempt (always NoOp) (Dom.focus "todo-input")
            )

        Save ->
            ( model, Nav.pushUrl model.key (Route.toString Route.Home) )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Template.Model -> Html Msg
view model template =
    let
        meetPrerequisite =
            not (String.isEmpty model.name) && not (List.isEmpty model.todos)
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
                    model.todos
                )
            ]
        , button [ onClick Save, disabled (not meetPrerequisite) ] [ text "Save" ]
        , text (Debug.toString template)
        , text (Debug.toString model)
        ]


getKey : Model -> Nav.Key
getKey model =
    model.key
