module Page.Home exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, button, div, li, text, ul)
import Html.Attributes exposing (class)
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
    | View String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Edit id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (EditPage id))) )

        View id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (ViewPage id))) )



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates todoTemplates) (ActualList todoList todo) model =
    div []
        [ text "home page"
        , ul []
            (Dict.foldl
                (\id template acc ->
                    li []
                        [ text template.name
                        , button [ onClick (Edit id), class "btn btn-link" ] [ text "Edit" ]
                        , button [ onClick (View id), class "btn btn-link" ] [ text "View " ]
                        ]
                        :: acc
                )
                []
                todoListTemplates
            )
        , text (Debug.toString todoListTemplates)
        , text (Debug.toString todoTemplates)
        ]



-- MISC


getKey : Model -> Nav.Key
getKey model =
    model.key


encoder : Template -> ActualList -> Model -> Json.Encode.Value
encoder template actualList model =
    Json.Encode.object
        [ ( "type", Json.Encode.string "Home" )
        , ( "model", Json.Encode.null )
        , ( "template", Template.encoder template )
        , ( "todoList", ActualList.encoder actualList )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.succeed { key = key }
