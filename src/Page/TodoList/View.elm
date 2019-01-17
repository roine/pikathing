module Page.TodoList.View exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (a, div, h1, h2, input, label, li, span, text, ul)
import Html.Attributes exposing (checked, class, href, type_)
import Json.Decode
import Json.Encode
import Route
import Template exposing (Template(..), getTodoByTemplateId)



-- MODEL


type alias Model =
    { key : Nav.Key, id : String }


init key id template =
    ( { key = key, id = id }, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update msg template actualList model =
    ( actualList, model, Cmd.none )



-- VIEW


view (Template todoListTemplates todoTemplates) (ActualList todoLists todos) { id } =
    let
        allData =
            Dict.get id todoLists
                |> Maybe.map
                    (\{ name, templateId } ->
                        { name = name
                        , templateId = templateId
                        , templateName = Maybe.map .name (Dict.get templateId todoListTemplates) |> Maybe.withDefault ""
                        , todos =
                            getTodoByTemplateId id todos
                                |> Debug.log "todos"
                                |> Dict.map
                                    (\id_ { completed, todoId } ->
                                        { name = Dict.get todoId todoTemplates |> Maybe.map .name |> Maybe.withDefault ""
                                        , completed = completed
                                        }
                                    )
                        }
                    )
                |> Debug.log "dsd"
    in
    div []
        (case allData of
            Nothing ->
                [ text "list not found" ]

            Just list ->
                [ h2 []
                    [ span [ class "mr-2" ]
                        [ a [ href (Route.toString (Route.Template (Route.ViewPage list.templateId))) ]
                            [ text list.templateName ]
                        ]
                    , span [] [ text ">" ]
                    , span [ class "ml-2" ] [ text list.name ]
                    ]
                , ul [ class "list-unstyled" ]
                    (List.map
                        (\todo ->
                            li [] [ label [] [ span [] [ input [ type_ "checkbox", class "mr-2", checked todo.completed ] [], span [] [ text todo.name ] ] ] ]
                        )
                        (Dict.values list.todos)
                    )
                ]
        )



-- MISC


getKey =
    .key


encoder model =
    Json.Encode.object [ ( "id", Json.Encode.string model.id ) ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.map2 Model
        (Json.Decode.succeed key)
        (Json.Decode.field "id" Json.Decode.string)