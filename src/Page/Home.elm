module Page.Home exposing (Model, Msg(..), decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, a, button, div, i, li, p, span, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import Route exposing (CrudPage(..))
import Set exposing (Set)
import Template exposing (Template(..), getTodoByTemplateId)



-- MODEL


type alias Model =
    { key : Nav.Key, expanded : Set String }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key, expanded = Set.empty }, Cmd.none )



-- UPDATE


type Msg
    = Expand String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Expand key ->
            ( { model
                | expanded =
                    if Set.member key model.expanded then
                        Set.remove key model.expanded

                    else
                        Set.insert key model.expanded
              }
            , Cmd.none
            )



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates todoTemplates) (ActualList todoList todo) model =
    div []
        [ if Dict.isEmpty todoListTemplates then
            p []
                [ text "You do not have a template yet, either import one or create one by clicking"
                , i [ class " mx-2 fa fa-plus-circle" ] []
                , text "."
                ]

          else
            ul [ class "list-unstyled" ]
                (Dict.foldl
                    (\id template acc ->
                        let
                            currentTodoLists =
                                getTodoByTemplateId id todoList

                            copyCount =
                                currentTodoLists |> Dict.size
                        in
                        li []
                            [ div [ class "row" ]
                                [ div [ class "col-8" ]
                                    [ text (template.name ++ "(" ++ String.fromInt copyCount ++ ")")
                                    , if Dict.isEmpty currentTodoLists then
                                        text ""

                                      else
                                        button [ onClick (Expand id) ]
                                            [ i
                                                [ classList
                                                    [ ( "fa", True )
                                                    , ( "fa-plus", not (Set.member id model.expanded) )
                                                    , ( "fa-minus", Set.member id model.expanded )
                                                    ]
                                                ]
                                                []
                                            ]
                                    , if Set.member id model.expanded then
                                        ul [ class "list-unstyled ml-4 my-2" ]
                                            (List.map
                                                (\( id_, todoList_ ) ->
                                                    li [ class "my-1" ]
                                                        [ a [ href (Route.toString (Route.TodoList (Route.ViewPage id_))) ] [ text todoList_.name ]
                                                        ]
                                                )
                                                (currentTodoLists |> Dict.toList)
                                            )

                                      else
                                        text ""
                                    ]
                                , div [ class "col-4 text-center" ]
                                    [ a [ href (Route.toString (Route.Template (Route.EditPage id))), class "badge badge-primary" ]
                                        [ i [ class "fa fa-pencil-alt" ] []
                                        ]
                                    , a [ href (Route.toString (Route.Template (Route.ViewPage id))), class "badge badge-secondary" ]
                                        [ i [ class "fa fa-eye" ] []
                                        ]
                                    ]
                                ]
                            ]
                            :: acc
                    )
                    []
                    todoListTemplates
                )
        , div [ class "fixed-bottom m-4" ] [ a [ href (Route.toString (Route.Template Route.AddPage)) ] [ i [ class "fa fa-plus-circle fa-2x" ] [] ] ]
        ]



-- MISC


getKey : Model -> Nav.Key
getKey model =
    model.key


encoder : Template -> ActualList -> Model -> Json.Encode.Value
encoder template actualList model =
    Json.Encode.object
        [ ( "type", Json.Encode.string "Home" )
        , ( "model", Json.Encode.object [ ( "expanded", Json.Encode.set Json.Encode.string model.expanded ) ] )
        , ( "template", Template.encoder template )
        , ( "todoList", ActualList.encoder actualList )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "model"
        (Json.Decode.map2 Model
            (Json.Decode.succeed key)
            (Json.Decode.field "expanded" (Json.Decode.list Json.Decode.string) |> Json.Decode.map Set.fromList)
        )
