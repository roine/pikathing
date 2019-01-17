module Page.Home exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, a, button, div, i, li, span, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Route exposing (CrudPage(..))
import Template exposing (Template(..), getTodoByTemplateId)



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
        [ if Dict.isEmpty todoListTemplates then
            div [] [ text "you do not have a template yet, either import one or create one by clicking", i [ class " mx-2 fa fa-plus-circle" ] [], text "." ]

          else
            ul [ class "list-unstyled" ]
                (Dict.foldl
                    (\id template acc ->
                        let
                            copyCount =
                                getTodoByTemplateId id todoList |> Dict.size
                        in
                        li []
                            [ div [ class "row" ]
                                [ div [ class "col-8" ]
                                    [ text (template.name ++ "(" ++ String.fromInt copyCount ++ ")")
                                    ]
                                , div [ class "col-4 text-center" ]
                                    [ a [ href (Route.toString (Route.Template (Route.EditPage id))), class "badge badge-primary" ] [ i [ class "fa fa-pencil-alt" ] [] ]
                                    , a [ href (Route.toString (Route.Template (Route.ViewPage id))), class "badge badge-secondary" ] [ i [ class "fa fa-eye" ] [] ]
                                    ]
                                ]
                            ]
                            :: acc
                    )
                    []
                    todoListTemplates
                )
        , a [ href (Route.toString (Route.Template Route.AddPage)) ] [ i [ class "fa fa-plus-circle fa-2x" ] [] ]
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
