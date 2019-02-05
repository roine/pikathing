module Page.Template.Edit exposing (Model, Msg, decoder, encoder, getKey, init, subscriptions, update, view)

import ActualList exposing (ActualList(..))
import Browser.Events
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (class, disabled, type_)
import Html.Events exposing (onClick)
import Icon
import Json.Decode
import Json.Encode
import Page.Template.Form as Form
import Random
import Route
import Template exposing (Template(..), TodoListTemplate, TodoTemplate, getTodoByTemplateId)
import Uuid.Barebones


type alias Model =
    { key : Nav.Key
    , form : Form.Model
    , meta : Bool -- check if Cmd (apple) or alt (Windows) is pressed
    }


init : Nav.Key -> Template -> String -> ( Model, Cmd Msg )
init key (Template todoListTemplates todoTemplates) id =
    let
        todoListTemplate =
            Dict.get id todoListTemplates

        todoTemplate =
            getTodoByTemplateId id todoTemplates
    in
    ( { key = key
      , form = Form.init id todoListTemplate todoTemplate
      , meta = False
      }
    , Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator
    )


type Msg
    = FormMsg Form.Msg
    | NewUIDForTodo String
    | Save
    | DoSave (Dict String TodoTemplate) (List String)
    | Delete
    | Cancel
    | NoOp



{- Save:
   Happens in two step because we need to generate the ids
   First step updates the Templates and generate the ids (id count = todolists using template * new todos)
   Second step updates ActualLists and navigate to home
-}


update : Msg -> Template -> ActualList -> Model -> { templates : Template, actualLists : ActualList, model : Model, cmd : Cmd Msg }
update msg ((Template todoListTemplates todoTemplates) as templates) ((ActualList todoLists todos) as actualLists) model =
    let
        form =
            model.form
    in
    case msg of
        FormMsg subMsg ->
            let
                ( newModel, cmd ) =
                    Form.update subMsg model.form
            in
            { templates = templates
            , actualLists = actualLists
            , model = { model | form = newModel }
            , cmd = Cmd.map FormMsg cmd
            }

        Save ->
            let
                newTodoCount =
                    Dict.diff model.form.todos todoTemplates |> Dict.size

                assignedTodolistCount =
                    getTodoByTemplateId model.form.id todoLists |> Dict.size
            in
            { templates = Template (Dict.insert model.form.id (Template.buildTodoList model.form) todoListTemplates) (Dict.union todoTemplates model.form.todos)
            , actualLists = actualLists
            , model = model
            , cmd =
                Random.generate
                    (DoSave (Dict.diff model.form.todos todoTemplates))
                    (Random.list (newTodoCount * assignedTodolistCount) Uuid.Barebones.uuidStringGenerator)
            }

        DoSave listNewTodoTemplates listIds ->
            let
                newTodos =
                    List.map2 Tuple.pair
                        listIds
                        (List.concatMap
                            (\( todoId, { templateId } ) ->
                                List.map
                                    (\listId ->
                                        { completed = False
                                        , templateId = listId
                                        , todoId = todoId
                                        }
                                    )
                                    (getTodoByTemplateId templateId todoLists |> Dict.keys)
                            )
                            (listNewTodoTemplates |> Dict.toList)
                        )
                        |> Dict.fromList
            in
            { templates = templates
            , actualLists = ActualList todoLists (Dict.union todos newTodos)
            , model = model
            , cmd = Nav.back model.key 1
            }

        Cancel ->
            { templates = templates
            , actualLists = actualLists
            , model = model
            , cmd = Nav.back model.key 1
            }

        NewUIDForTodo newUuid ->
            { templates = templates
            , actualLists = actualLists
            , model = { model | form = { form | nextTodoId = newUuid } }
            , cmd = Cmd.none
            }

        Delete ->
            let
                newTodoListTemplates =
                    todoListTemplates |> Dict.remove model.form.id

                todoTemplateKeys =
                    getTodoByTemplateId model.form.id todoTemplates |> Dict.keys

                newTodoTemplates =
                    List.foldl (\keyToDelete dict -> Dict.remove keyToDelete dict) todoTemplates todoTemplateKeys

                todoListKeys =
                    getTodoByTemplateId model.form.id todoLists |> Dict.keys

                newTodoLists =
                    List.foldl (\keyToDelete dict -> Dict.remove keyToDelete dict) todoLists todoListKeys

                todoKeys =
                    List.concatMap (\keys -> getTodoByTemplateId keys todos |> Dict.keys) todoListKeys

                newTodos =
                    List.foldl (\keyToDelete dict -> Dict.remove keyToDelete dict) todos todoKeys
            in
            { templates = Template newTodoListTemplates newTodoTemplates
            , actualLists = ActualList newTodoLists newTodos
            , model = model
            , cmd = Nav.pushUrl model.key (Route.toString Route.Home)
            }

        NoOp ->
            { templates = templates, actualLists = actualLists, model = model, cmd = Cmd.none }


view : Template -> ActualList -> Model -> Html Msg
view template actualList model =
    let
        meetPrerequisite =
            not (String.isEmpty model.form.name) && not (Dict.isEmpty model.form.todos)
    in
    div []
        [ Html.map FormMsg (Form.view template actualList model.form)
        , div [ class "row" ]
            [ div [ class "col-6" ] [ button [ onClick Cancel, class "btn btn-warning", type_ "button" ] [ text "Cancel" ] ]
            , div [ class "col-6 text-right" ]
                [ button
                    [ onClick Save
                    , disabled (not meetPrerequisite)
                    , class "btn btn-success"
                    , type_ "button"
                    ]
                    [ text "Update" ]
                ]
            ]
        , div [ class "row mt-3 text-right" ]
            [ div []
                [ span [ class "mr-2 vertical-center" ]
                    [ text "Delete your template" ]
                ]
            , button [ class "btn btn-danger", onClick Delete ] [ Icon.view [] Icon.Trash ]
            ]
        ]



-- MISC


subscriptions : Template -> ActualList -> Model -> Sub Msg
subscriptions template actualList model =
    Browser.Events.onKeyDown
        (Json.Decode.map2
            (\meta key ->
                if meta && key == "Enter" then
                    Save

                else
                    NoOp
            )
            (Json.Decode.field "metaKey" Json.Decode.bool)
            (Json.Decode.field "key" Json.Decode.string)
        )


getKey : Model -> Nav.Key
getKey =
    .key


encoder : Model -> Json.Encode.Value
encoder model =
    Json.Encode.object
        [ ( "form", Form.encoder model.form )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map3 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "form" Form.decoder)
        (Json.Decode.succeed False)
