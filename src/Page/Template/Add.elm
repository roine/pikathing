module Page.Template.Add exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Color exposing (Color)
import Colour.Extra
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, i, input, label, li, text, ul)
import Html.Attributes exposing (class, disabled, id, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Icon exposing (Icon)
import Json.Decode
import Json.Encode
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
    , transient : { name : String }
    , icon : Maybe Icon
    , colour : Color
    }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key
      , name = ""
      , id = ""
      , todos = Dict.fromList []
      , transient = { name = "" }
      , nextTodoId = ""
      , icon = Nothing
      , colour = Color.black
      }
    , Cmd.batch
        [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
        , Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator
        , Random.generate NewColor (Random.map3 Color.rgb (Random.float 0 1) (Random.float 0 1) (Random.float 0 1))
        ]
    )



-- Avilable icons to be picked up


availableIconsList : List Icon
availableIconsList =
    [ Icon.Home, Icon.Laptop, Icon.Car, Icon.Book, Icon.Bed ]



-- UPDATE


type Msg
    = UpdateName String
    | UpdateTransientName String
    | Add
    | Save
    | NewUIDForTodoList String
    | NewUIDForTodo String
    | SelectIcon Icon
    | Cancel
    | NewColor Color
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
            ( Template (Dict.insert model.id (Template.buildTodoList model) todoListTemplates) (Dict.union todoTemplates model.todos)
            , model
            , Nav.pushUrl model.key (Route.toString Route.Home)
            )

        NoOp ->
            ( templates, model, Cmd.none )

        NewUIDForTodoList newUuid ->
            ( templates, { model | id = newUuid }, Cmd.none )

        NewUIDForTodo newUuid ->
            ( templates, { model | nextTodoId = newUuid }, Cmd.none )

        Cancel ->
            ( templates
            , model
            , Nav.back model.key 1
            )

        SelectIcon icon ->
            ( templates
            , { model | icon = Just icon }
            , Cmd.none
            )

        NewColor newColour ->
            ( templates
            , { model | colour = newColour }
            , Cmd.none
            )



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view template actualList model =
    let
        meetPrerequisite =
            not (String.isEmpty model.name) && not (Dict.isEmpty model.todos)

        onEnter tagger =
            on "keydown"
                (Json.Decode.field "key" Json.Decode.string
                    |> Json.Decode.andThen
                        (\key ->
                            if key == "Enter" then
                                Json.Decode.succeed tagger

                            else
                                Json.Decode.fail "Other than Enter"
                        )
                )

        colourStyle colour active =
            [ style "background"
                (if active then
                    Color.toCssString (Colour.Extra.mix 0.4 Color.white colour)

                 else
                    Color.toCssString (Colour.Extra.mix 0.7 Color.white colour)
                )
            , style "color" (Color.toCssString (Colour.Extra.mix 0.4 Color.black colour))
            , style "border" ("1px solid " ++ Color.toCssString (Colour.Extra.mix 0.5 Color.white colour))
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
            , div [ class "row justify-content-start" ]
                (List.map
                    (\icon ->
                        div [ class "col-auto my-2" ]
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
        , div [ class "row" ]
            [ div [ class "col-6" ] [ button [ onClick Cancel, class "btn btn-danger", type_ "button" ] [ text "Cancel" ] ]
            , div [ class "col-6 text-right" ]
                [ button
                    [ onClick Save
                    , disabled (not meetPrerequisite)
                    , class "btn btn-success"
                    , type_ "button"
                    ]
                    [ text "Save" ]
                ]
            ]
        ]



-- MISC


getKey : Model -> Nav.Key
getKey =
    .key


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


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map8 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "nextTodoId" Json.Decode.string)
        (Json.Decode.field "todos"
            (Json.Decode.dict
                (Json.Decode.map2 TodoTemplate
                    (Json.Decode.field "name" Json.Decode.string)
                    (Json.Decode.field "templateId" Json.Decode.string)
                )
            )
        )
        (Json.Decode.field "transient" (Json.Decode.map (\name -> { name = name }) (Json.Decode.field "name" Json.Decode.string)))
        (Json.Decode.maybe (Json.Decode.field "icon" Json.Decode.string) |> Json.Decode.map (Maybe.andThen Icon.fromString))
        (Json.Decode.field "colour"
            (Json.Decode.map4
                Color.rgba
                (Json.Decode.field "red" Json.Decode.float)
                (Json.Decode.field "green" Json.Decode.float)
                (Json.Decode.field "blue" Json.Decode.float)
                (Json.Decode.field "alpha" Json.Decode.float)
            )
        )
