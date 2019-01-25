module Page.Template.View exposing (Model, Msg, decoder, encoder, getKey, init, subscriptions, update, view)

import ActualList exposing (ActualList(..))
import Animation
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
import Parser exposing ((|.), (|=), Parser)
import Random
import Route
import Task
import Template exposing (Template(..), TodoTemplate, getTodoByTemplateId)
import Uuid.Barebones


type alias Model =
    { key : Nav.Key
    , templateId : String
    , name : String
    , id : String
    , nextTodoIds : List String
    , filter : String
    , transition : Dict String Animation.Status
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
      , transition = Dict.empty
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
    | UpdateTransitionTime Float
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
                , { model | name = "", transition = Dict.insert model.id (Animation.Enter Animation.Initial 300) model.transition }
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

        UpdateTransitionTime delta ->
            ( actualList
            , { model
                | transition =
                    Dict.foldl
                        (\key value acc ->
                            let
                                updatedTime =
                                    Animation.mapTime
                                        (\oldTime ->
                                            oldTime - delta
                                        )
                                        value
                            in
                            if Animation.isInitial value then
                                case Animation.nextState value of
                                    Just nextState ->
                                        Dict.insert key nextState acc

                                    Nothing ->
                                        acc

                            else if Animation.getTime updatedTime <= 0 then
                                case Animation.nextState value of
                                    Just nextState ->
                                        Dict.insert key nextState acc

                                    Nothing ->
                                        acc

                            else
                                Dict.insert key updatedTime acc
                        )
                        Dict.empty
                        model.transition
              }
            , Cmd.none
            )

        NoOp ->
            ( actualList, model, Cmd.none )


type Comp
    = Eq Float
    | Gt Float
    | Lt Float


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
            let
                trimmedFilter =
                    String.trim model.filter

                expression =
                    Parser.succeed identity
                        |= compParser
                        |. Parser.spaces
                        |= Parser.float

                compParser =
                    Parser.oneOf
                        [ Parser.map (always Eq) (Parser.symbol "=")
                        , Parser.map (always Lt) (Parser.symbol "<")
                        , Parser.map (always Gt) (Parser.symbol ">")
                        ]

                parse =
                    Parser.run expression
            in
            case parse trimmedFilter of
                Err err ->
                    Dict.filter (\key { name } -> String.contains (String.toUpper trimmedFilter) (String.toUpper name)) currentTodoLists

                Ok res ->
                    Dict.filter
                        (\key { name } ->
                            let
                                currentTodos =
                                    getTodoByTemplateId key todos

                                points =
                                    currentTodos
                                        |> Dict.filter (\_ todo -> todo.completed)
                                        |> Dict.size
                                        |> (\completedCount ->
                                                toFloat completedCount / toFloat (Dict.size currentTodos) * 100
                                           )
                            in
                            case res of
                                Gt num ->
                                    num < points

                                Lt num ->
                                    num > points

                                Eq num ->
                                    num == points
                        )
                        currentTodoLists
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
                            , placeholder "Filter either the name or the points, eg: < 80"
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
                            let
                                currentTodos =
                                    getTodoByTemplateId id todos

                                points =
                                    currentTodos
                                        |> Dict.filter (\key todo -> todo.completed)
                                        |> Dict.size
                                        |> (\completedCount ->
                                                toFloat completedCount / toFloat (Dict.size currentTodos) * 100
                                           )
                            in
                            li [ class gridRule, class (transitionToClass "linked-panel-animation" model.transition id) ]
                                [ div [ class "linked-panel list-group", onClick (NavigateView id) ]
                                    [ h4 [ class "linked-panel-title text-center" ] [ text todoList.name ]
                                    , div [ class "linked-panel-subtitle text-center" ] [ text (String.fromFloat points ++ "%") ]
                                    , div [ class "linked-panel-navigation-clue" ]
                                        [ i [ class "fa fa-arrow-right" ] [] ]
                                    ]
                                ]
                        )
                        (Dict.toList filteredCurrentTodoLists)
                    )
                ]


transitionToClass prefix transitions id =
    case Dict.get id transitions of
        Nothing ->
            ""

        Just (Animation.Enter Animation.Initial _) ->
            prefix ++ "-enter"

        Just (Animation.Enter Animation.Active _) ->
            prefix ++ "-enter " ++ prefix ++ "-enter-active"

        _ ->
            ""



-- MISC


subscriptions : Template -> ActualList -> Model -> Sub Msg
subscriptions template actualList model =
    if Dict.isEmpty model.transition then
        Sub.none

    else
        onAnimationFrameDelta UpdateTransitionTime


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
        (Json.Decode.succeed Dict.empty)
