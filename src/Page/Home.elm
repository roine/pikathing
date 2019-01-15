module Page.Home exposing (Model, Msg(..), getKey, init, update, view)

import Browser.Navigation as Nav
import Html exposing (Html, button, div, text)
import Template



-- MODEL


type alias Model =
    { key : Nav.Key }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key }, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Template.Model -> Html Msg
view model template =
    div [] [ text "home page" ]


getKey : Model -> Nav.Key
getKey model =
    model.key
