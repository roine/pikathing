module Page.Template.Add exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Color exposing (Color)
import Dict exposing (Dict)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, disabled, type_)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Page.Template.Form as Form
import Random
import Route
import Template exposing (Template(..), TodoListTemplate, TodoTemplate)
import Uuid.Barebones



-- MODEL


type alias Model =
    { key : Nav.Key
    , form : Form.Model
    }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key
      , form = Form.init "" Nothing Dict.empty
      }
    , Cmd.batch
        [ Random.generate NewUIDForTodoList Uuid.Barebones.uuidStringGenerator
        , Random.generate NewUIDForTodo Uuid.Barebones.uuidStringGenerator
        , Random.generate NewColor (Random.map3 Color.rgb (Random.float 0 1) (Random.float 0 1) (Random.float 0 1))
        ]
    )



-- UPDATE


type Msg
    = Save
    | Cancel
    | NewUIDForTodoList String
    | NewUIDForTodo String
    | NewColor Color
    | FormMsg Form.Msg
    | NoOp


update : Msg -> Template -> Model -> ( Template, Model, Cmd Msg )
update msg ((Template todoListTemplates todoTemplates) as templates) model =
    let
        form =
            model.form
    in
    case msg of
        Save ->
            ( Template (Dict.insert model.form.id (Template.buildTodoList model.form) todoListTemplates) (Dict.union todoTemplates model.form.todos)
            , model
            , Nav.pushUrl model.key (Route.toString Route.Home)
            )

        NoOp ->
            ( templates, model, Cmd.none )

        NewUIDForTodoList newUuid ->
            ( templates, { model | form = { form | id = newUuid } }, Cmd.none )

        NewUIDForTodo newUuid ->
            ( templates, { model | form = { form | nextTodoId = newUuid } }, Cmd.none )

        Cancel ->
            ( templates
            , model
            , Nav.back model.key 1
            )

        NewColor newColour ->
            ( templates
            , { model | form = { form | colour = newColour } }
            , Cmd.none
            )

        FormMsg subMsg ->
            let
                ( newModel, cmd ) =
                    Form.update subMsg model.form
            in
            ( templates, { model | form = newModel }, Cmd.map FormMsg cmd )



-- VIEW


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
    Json.Encode.object
        [ ( "form", Form.encoder model.form )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map2 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "form" Form.decoder)
