module Page.Template.Edit exposing (Model, Msg, decoder, encoder, getKey, init, subscriptions, update, view)

import ActualList exposing (ActualList(..))
import Browser.Events
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, disabled, type_)
import Html.Events exposing (onClick)
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
            , cmd = Random.generate (DoSave (Dict.diff model.form.todos todoTemplates)) (Random.list (newTodoCount * assignedTodolistCount) Uuid.Barebones.uuidStringGenerator)
            }

        DoSave listNewTodoTemplates listIds ->
            let
                newTodos =
                    List.map2
                        (\todolistId todoId ->
                            List.map
                                (\( todoTemplateId, todo ) ->
                                    ( todoId
                                    , { templateId = todolistId
                                      , completed = False
                                      , todoId = todoTemplateId
                                      }
                                    )
                                )
                                (Dict.toList listNewTodoTemplates)
                        )
                        (getTodoByTemplateId model.form.id todoLists |> Dict.keys)
                        listIds
                        |> List.concat
                        |> Dict.fromList
            in
            { templates = templates
            , actualLists = ActualList todoLists (Dict.union newTodos todos)
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
            [ div [ class "col-6" ] [ button [ onClick Cancel, class "btn btn-danger", type_ "button" ] [ text "Cancel" ] ]
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
