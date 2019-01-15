module Page.Home exposing (Model, Msg(..), getKey, init, update, view)

import Browser.Navigation as Nav
import Dict
import Html exposing (Html, button, div, li, text, ul)
import Html.Events exposing (onClick)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Edit id ->
            ( model, Nav.pushUrl model.key (Route.toString (Route.Template (EditPage id))) )



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
        , text (Debug.toString todoListTemplates)
        , text (Debug.toString todoTemplates)
        ]


getKey : Model -> Nav.Key
getKey model =
    model.key
