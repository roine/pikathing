module Page.Home exposing (Model, Msg(..), decoder, encoder, getKey, init, subscriptions, update, view)

import ActualList exposing (ActualList(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Color
import Colour.Extra
import Dict
import Html exposing (Html, a, button, div, h4, i, input, li, p, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, placeholder, required, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Icon
import Json.Decode
import Json.Encode
import Route exposing (CrudPage(..))
import Task
import Template exposing (Template(..), getTodoByTemplateId)



-- MODEL


type alias Model =
    { key : Nav.Key, filter : String }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key, filter = "" }, Task.attempt (always NoOp) (Dom.focus "filter-input") )



-- UPDATE


type Msg
    = NavigateToEdit String
    | NavigateView String
    | Filter String
    | ClearFilter
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateToEdit id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (Route.EditPage id))) )

        NavigateView id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (Route.ViewPage id))) )

        Filter text ->
            ( { model | filter = text }, Cmd.none )

        ClearFilter ->
            ( { model | filter = "" }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


pluralize count singular plural =
    if count == 1 then
        String.fromInt count ++ " " ++ singular

    else
        String.fromInt count ++ " " ++ plural


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates todoTemplates) (ActualList todoList todo) model =
    let
        colourStyle colour =
            [ style "background" (Color.toCssString (Colour.Extra.mix 0.7 Color.white colour))
            , style "color" (Color.toCssString (Colour.Extra.mix 0.4 Color.black colour))
            , style "border" ("1px solid " ++ Color.toCssString (Colour.Extra.mix 0.5 Color.white colour))
            ]

        gridRule =
            "col-sm-6 col-xl-3 px-1 py-1"

        filteredTodoListTemplates =
            if String.isEmpty (String.trim model.filter) then
                todoListTemplates

            else
                Dict.filter (\k { name } -> String.contains (String.toUpper model.filter) (String.toUpper name)) todoListTemplates
    in
    div [ class "list-group" ]
        [ if Dict.isEmpty todoListTemplates then
            p []
                [ text "You do not have a template yet, either import one or create one by clicking"
                , i [ class " mx-2 fa fa-plus-circle" ] []
                , text "."
                ]

          else
            div [ class "row my-2" ]
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
            ((li [ class gridRule ]
                [ a [ href (Route.toString (Route.Template Route.AddPage)), class "linked-panel" ]
                    [ h4 [ class "linked-panel-title absolute-center" ] [ text "+" ]
                    ]
                ]
                :: Dict.foldl
                    (\id template acc ->
                        let
                            currentTodoLists =
                                getTodoByTemplateId id todoList

                            copyCount =
                                currentTodoLists |> Dict.size

                            criteriaCount =
                                getTodoByTemplateId id todoTemplates |> Dict.size

                            hasIcon =
                                case template.icon of
                                    Nothing ->
                                        False

                                    Just _ ->
                                        True
                        in
                        li [ class gridRule ]
                            [ div
                                [ classList [ ( "linked-panel list-group", True ), ( "linked-panel-with-icon", hasIcon ) ]
                                , onClick (NavigateView id)
                                ]
                                [ case template.icon of
                                    Nothing ->
                                        text ""

                                    Just icon ->
                                        div [ class "text-center" ]
                                            [ Icon.view
                                                ([ class "icon-circle"
                                                 ]
                                                    ++ colourStyle template.colour
                                                )
                                                icon
                                            ]
                                , h4 [ class "linked-panel-title text-center" ]
                                    [ text template.name
                                    ]
                                , div [ class "text-center linked-panel-subtitle" ]
                                    [ span [ class "badge badge-dark badge-pill" ] [ text (String.fromInt copyCount) ]
                                    ]
                                , button [ onClick (NavigateToEdit id), class "linked-panel-edit" ]
                                    [ i [ class "fa fa-pencil-alt" ] []
                                    ]
                                , div [ class "linked-panel-navigation-clue" ]
                                    [ i [ class "fa fa-arrow-right" ] [] ]
                                ]
                            ]
                            :: acc
                    )
                    []
                    filteredTodoListTemplates
             )
                |> List.reverse
            )
        ]



-- MISC


subscriptions : Template -> ActualList -> Model -> Sub Msg
subscriptions templates actualLists model =
    Sub.none


getKey : Model -> Nav.Key
getKey model =
    model.key


encoder : Template -> ActualList -> Model -> Json.Encode.Value
encoder template actualList model =
    Json.Encode.object
        [ ( "type", Json.Encode.string "Home" )
        , ( "model", Json.Encode.object [ ( "filter", Json.Encode.string model.filter ) ] )
        , ( "template", Template.encoder template )
        , ( "todoList", ActualList.encoder actualList )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "model"
        (Json.Decode.map2 Model
            (Json.Decode.succeed key)
            (Json.Decode.field "filter" Json.Decode.string)
        )
