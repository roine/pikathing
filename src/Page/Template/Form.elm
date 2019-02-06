module Page.Template.Form exposing (Model, Msg, decoder, encoder, init, update, view)

import ActualList exposing (ActualList(..), Todo)
import Browser.Dom as Dom
import Color exposing (Color)
import Colour.Extra
import Dict exposing (Dict)
import Html exposing (Html, button, div, i, input, label, li, text, ul)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Html.Extra exposing (onEnter)
import Icon exposing (Icon)
import Json.Decode
import Json.Encode
import Random
import Task
import Template exposing (Template(..), TodoTemplate)
import Uuid.Barebones



-- MODEL


type alias Model =
    { todos : Dict String TodoTemplate
    , id : String
    , name : String
    , transient : { name : String }
    , colour : Color
    , icon : Maybe Icon
    , nextTodoId : String
    }


init : String -> Maybe { name : String, icon : Maybe Icon, colour : Color } -> Dict String TodoTemplate -> Model
init id maybeData todos =
    let
        defaultModel =
            { name = ""
            , id = id
            , todos = todos
            , transient = { name = "" }
            , nextTodoId = ""
            , icon = Nothing
            , colour = Color.black
            }
    in
    case maybeData of
        Nothing ->
            defaultModel

        Just { name, icon, colour } ->
            { defaultModel | name = name, icon = icon, colour = colour }



-- UPDATE


type Msg
    = UpdateName String
    | UpdateTransientName String
    | Add
    | SelectIcon Icon
    | NewUIDForTodo String
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
            if String.isEmpty (String.trim model.transient.name) then
                ( model, Cmd.none )

            else
                ( { model
                    | todos = Dict.insert model.nextTodoId { name = model.transient.name, templateId = model.id } model.todos
                    , transient = { transient | name = "" }
                  }
                , Cmd.batch
                    [ Task.attempt (always NoOp) (Dom.focus "todo-input")
                    , Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator
                    ]
                )

        NewUIDForTodo newUuid ->
            ( { model | nextTodoId = newUuid }, Cmd.none )

        SelectIcon icon ->
            ( { model | icon = Just icon }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW
-- Available icons to be picked up


availableIconsList : List Icon
availableIconsList =
    [ Icon.Home, Icon.Laptop, Icon.Car, Icon.Book, Icon.Bed, Icon.Briefcase ]


view : Template -> ActualList -> Model -> Html Msg
view template actualList model =
    let
        meetPrerequisite =
            not (String.isEmpty model.name) && not (Dict.isEmpty model.todos)

        colourStyle colour active =
            [ style "background"
                (if active then
                    Color.toCssString (Colour.Extra.mix 0.4 Color.white colour)

                 else
                    Color.toCssString (Colour.Extra.mix 0.7 Color.white colour)
                )
            , style "color" (Color.toCssString (Colour.Extra.mix 0.4 Color.black colour))
            , style "border" ("1px solid " ++ Color.toCssString (Colour.Extra.mix 0.4 Color.white colour))
            , style "transition" "300ms all ease"
            ]
    in
    div []
        [ div [ class "form-group mb-2" ]
            [ label [ class "sr-only" ] [ text "Template name" ]
            , input
                [ value model.name
                , class "form-control"
                , onInput UpdateName
                , placeholder "Template Name"
                ]
                []
            ]
        , div [ class "form-group mb-2" ]
            [ label [ class "sr-only" ] [ text "Todo" ]
            , div [ class "input-group mb-2" ]
                [ input
                    [ value model.transient.name
                    , class "form-control mr-2"
                    , onInput UpdateTransientName
                    , onEnter Add
                    , id "todo-input"
                    , placeholder "Todo"
                    ]
                    []
                , div [ class "input-group-append" ]
                    [ button [ onClick Add, type_ "button", class "btn btn-link form-control" ]
                        [ i [ class "fa fa-plus fa-lg" ] []
                        ]
                    ]
                ]
            ]
        , ul []
            (List.map
                (\todo ->
                    li [] [ text todo.name ]
                )
                (Dict.values model.todos)
            )
        , div []
            [ text "Optionally Pick an icon"
            , div [ class "row justify-content-start my-3" ]
                (List.map
                    (\icon ->
                        div [ class "col-auto" ]
                            [ div [ onClick (SelectIcon icon), class "pointer" ]
                                [ Icon.view
                                    ([ class "icon-circle"
                                     ]
                                        ++ colourStyle model.colour (Just icon == model.icon)
                                    )
                                    icon
                                ]
                            ]
                    )
                    availableIconsList
                )
            ]
        ]



-- MISC


encoder : Model -> Json.Encode.Value
encoder model =
    let
        withIcon =
            case model.icon of
                Nothing ->
                    []

                Just icon ->
                    [ ( "icon", Json.Encode.string (Icon.toString icon) ) ]
    in
    Json.Encode.object
        ([ ( "name", Json.Encode.string model.name )
         , ( "id", Json.Encode.string model.id )
         , ( "nextTodoId", Json.Encode.string model.nextTodoId )
         , ( "todos"
           , Json.Encode.dict identity
                (\{ name, templateId } ->
                    Json.Encode.object [ ( "name", Json.Encode.string name ), ( "templateId", Json.Encode.string templateId ) ]
                )
                model.todos
           )
         , ( "transient", Json.Encode.object [ ( "name", Json.Encode.string model.transient.name ) ] )
         , ( "colour"
           , Json.Encode.object
                [ ( "red", Json.Encode.float (.red (Color.toRgba model.colour)) )
                , ( "green", Json.Encode.float (.green (Color.toRgba model.colour)) )
                , ( "blue", Json.Encode.float (.blue (Color.toRgba model.colour)) )
                , ( "alpha", Json.Encode.float (.alpha (Color.toRgba model.colour)) )
                ]
           )
         ]
            ++ withIcon
        )


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map7 Model
        (Json.Decode.field "todos"
            (Json.Decode.dict
                (Json.Decode.map2 TodoTemplate
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.field "templateId" Json.Decode.string)
                )
            )
        )
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "transient" (Json.Decode.map (\name -> { name = name }) (Json.Decode.field "name" Json.Decode.string)))
        (Json.Decode.field "colour"
            (Json.Decode.map4
                Color.rgba
                (Json.Decode.field "red" Json.Decode.float)
                (Json.Decode.field "green" Json.Decode.float)
                (Json.Decode.field "blue" Json.Decode.float)
                (Json.Decode.field "alpha" Json.Decode.float)
            )
        )
        (Json.Decode.maybe (Json.Decode.field "icon" Json.Decode.string) |> Json.Decode.map (Maybe.andThen Icon.fromString))
        (Json.Decode.field "nextTodoId" Json.Decode.string)
