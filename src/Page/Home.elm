module Page.Home exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import Browser.Navigation as Nav
import Dict
import Html exposing (Html, button, div, li, text, ul)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Route exposing (SubTemplatePage(..))
import Template exposing (Template(..))



-- MODEL


type alias Model =
    { key : Nav.Key }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key }, Cmd.none )



-- UPDATE


type Msg
    = Edit String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Edit id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (EditPage id))) )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Template -> Html Msg
view model (Template todoListTemplates todoTemplates) =
    div []
        [ text "home page"
        , ul []
            (Dict.foldl
                (\id template acc ->
                    li [] [ text template.name, button [ onClick (Edit id) ] [ text "Edit" ] ] :: acc
                )
                []
                todoListTemplates
            )
        , button [ onClick NoOp ] [ text "te" ]
        , text (Debug.toString todoListTemplates)
        , text (Debug.toString todoTemplates)
        ]



-- MISC


getKey : Model -> Nav.Key
getKey model =
    model.key


encoder : Model -> Template -> Json.Encode.Value
encoder model template =
    Json.Encode.object [ ( "type", Json.Encode.string "Home" ), ( "model", Json.Encode.null ), ( "template", Template.encoder template ) ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.succeed { key = key }
