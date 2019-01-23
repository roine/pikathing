module Page.Template.View exposing (Model, Msg, decoder, encoder, getKey, init, subscriptions, update, view)

import ActualList exposing (ActualList(..))
import Browser.Dom as Dom
import Browser.Events exposing (onAnimationFrameDelta)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h2, h4, i, input, label, li, span, text, ul)
import Html.Attributes exposing (class, href, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Html.Extra exposing (onEnter)
import Icon
import Json.Decode
import Json.Encode
import Random
import Route
import Task
import Template exposing (Template(..), TodoTemplate, getTodoByTemplateId)
import Time exposing (Posix)
import Transition
import Uuid.Barebones


type alias Model =
    { key : Nav.Key
    , templateId : String
    , name : String
    , id : String
    , nextTodoIds : List String
    , filter : String
    , animations : Transition.Model
    }



-- Count how many todos assign to this template


todoCount : String -> Dict String TodoTemplate -> Int
todoCount templateId todoTemplate =
    getTodoByTemplateId templateId todoTemplate
        |> Dict.size


init : Nav.Key -> String -> Template -> ( Model, Cmd Msg )
init key templateId (Template _ todoTemplate) =
    ( { key = key
      , templateId = templateId
      , name = ""
      , id = ""
      , nextTodoIds = []
      , filter = ""
      , animations = Transition.init
      }
    , Cmd.batch
        [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
        , Random.generate NewUIDForTodo (Random.list (todoCount templateId todoTemplate) Uuid.Barebones.uuidStringGenerator)
        , Task.attempt (always NoOp) (Dom.focus "copy-input")
        ]
    )


type Msg
    = UpdateName String
    | MakeCopy
    | NewUIDForTodoList String
    | NewUIDForTodo (List String)
    | NavigateView String
    | Filter String
    | ClearFilter
    | UpdateTransitionTime Posix
    | NoOp


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
            if String.isEmpty (String.trim model.name) then
                ( actualList, model, Cmd.none )

            else
                ( ActualList (Dict.union newTodoList todoLists) (Dict.union newTodos todos)
                , { model | name = "", animations = Transition.add model.id (Transition.Enter Transition.Initial 10000) model.animations }
                , Cmd.batch
                    [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
                    , Random.generate NewUIDForTodo (Random.list (todoCount model.templateId todoTemplate) Uuid.Barebones.uuidStringGenerator)
                    , Task.attempt (always NoOp) (Dom.focus "copy-input")
                    ]
                )

        NewUIDForTodoList uid ->
            ( actualList, { model | id = uid }, Cmd.none )

        NewUIDForTodo uids ->
            ( actualList, { model | nextTodoIds = uids }, Cmd.none )

        NavigateView id ->
            ( actualList, model, Nav.pushUrl model.key (Route.toString (Route.TodoList (Route.ViewPage id))) )

        Filter text ->
            ( actualList, { model | filter = text }, Cmd.none )

        ClearFilter ->
            ( actualList, { model | filter = "" }, Cmd.none )

        NoOp ->
            ( actualList, model, Cmd.none )

        UpdateTransitionTime now ->
            ( actualList
            , { model
                | animations =
                    Transition.update now model.animations
              }
            , Cmd.none
            )


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates _) (ActualList todoLists todos) model =
    let
        currentTodoLists =
            getTodoByTemplateId model.templateId todoLists

        maybeTemplate =
            Dict.get model.templateId todoListTemplates

        gridRule =
            "col-sm-6 col-xl-3 px-1 py-1"

        filteredCurrentTodoLists =
            Dict.filter (\key { name } -> String.contains (String.toUpper model.filter) (String.toUpper name)) currentTodoLists
    in
    case maybeTemplate of
        Nothing ->
            div [] [ text "This template does not exists" ]

        Just template ->
            div []
                [ div [ class "row align-items-center" ]
                    [ h2 [ class "col-auto pr-1" ]
                        [ text template.name
                        ]
                    , div [ class "col-auto pl-1" ]
                        [ a [ href (Route.toString (Route.Template (Route.EditPage model.templateId))), class "badge badge-primary" ]
                            [ i [ class "fa fa-pencil-alt" ] []
                            ]
                        ]
                    ]
                , div [ class "form-row mb-5" ]
                    [ div [ class "col-auto " ]
                        [ label [ class "sr-only" ] [ text "Name" ]
                        , input
                            [ onInput UpdateName
                            , value model.name
                            , class "form-control"
                            , placeholder "Name of the copy, eg: Porsche"
                            , onEnter MakeCopy
                            , id "copy-input"
                            ]
                            []
                        ]
                    , div [ class "col-auto" ]
                        [ button
                            [ onClick MakeCopy
                            , class "btn btn-primary"
                            ]
                            [ text "Make a new copy" ]
                        ]
                    ]
                , div [ class "row my-2" ]
                    [ div [ class "input-group mx-1" ]
                        [ input
                            [ type_ "text"
                            , id "filter-input"
                            , class "form-control"
                            , placeholder "Filter"
                            , onInput Filter
                            , value model.filter
                            ]
                            []
                        , if String.isEmpty model.filter then
                            text ""

                          else
                            span [ class "input-cross", onClick ClearFilter ] [ Icon.view [] Icon.Cross ]
                        ]
                    ]
                , ul [ class "list-unstyled row" ]
                    (List.map
                        (\( id, todoList ) ->
                            li [ class gridRule, class (transitionToClass "linked-panel-animation" model.animations id) ]
                                [ div [ class "linked-panel list-group", onClick (NavigateView id) ]
                                    [ h4 [ class "linked-panel-title text-center" ] [ text todoList.name ]
                                    , div [ class "linked-panel-navigation-clue" ]
                                        [ i [ class "fa fa-arrow-right" ] [] ]
                                    ]
                                ]
                        )
                        (Dict.toList filteredCurrentTodoLists)
                    )
                ]


transitionToClass : String -> Transition.Model -> String -> String
transitionToClass prefix animations id =
    case Dict.get id animations.transitions of
        Nothing ->
            ""

        Just transition ->
            Transition.toClass prefix transition.status



-- MISC


subscriptions : Template -> ActualList -> Model -> Sub Msg
subscriptions template actualList model =
    Transition.subscriptions model.animations UpdateTransitionTime


getKey : Model -> Nav.Key
getKey =
    .key


encoder : Model -> Json.Encode.Value
encoder model =
    Json.Encode.object
        [ ( "templateId", Json.Encode.string model.templateId )
        , ( "name", Json.Encode.string model.name )
        , ( "id", Json.Encode.string model.id )
        , ( "nextTodoIds", Json.Encode.list Json.Encode.string model.nextTodoIds )
        , ( "filter", Json.Encode.string model.filter )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map7 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "templateId" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "nextTodoIds" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "filter" Json.Decode.string)
        Transition.decoder
