module Page.Compare exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import ActualList exposing (ActualList(..))
import Browser.Navigation as Nav
import Dict
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class, classList, style)
import Icon
import Json.Decode
import Json.Decode.Extra
import Json.Encode
import Json.Encode.Extra
import Template exposing (Template(..), getTodoByTemplateId)


type alias Model =
    { comparableId : ( String, String ), key : Nav.Key }


init id1 id2 key =
    ( { comparableId = ( id1, id2 )
      , key = key
      }
    , Cmd.none
    )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Template -> ActualList -> Model -> Html Msg
view (Template todoListTemplates todoTemplates) (ActualList todolists todos) model =
    let
        all =
            List.map2
                (\list1 list2 ->
                    { name = Dict.get list1.todoId todoTemplates |> Maybe.map .name |> Maybe.withDefault ""
                    , completed1 = list1.completed
                    , completed2 = list2.completed
                    }
                )
                (getTodoByTemplateId (Tuple.first model.comparableId) todos |> Dict.values)
                (getTodoByTemplateId (Tuple.second model.comparableId) todos |> Dict.values)

        template1Name =
            Dict.get (Tuple.first model.comparableId) todolists |> Maybe.map .name |> Maybe.withDefault ""

        template2Name =
            Dict.get (Tuple.second model.comparableId) todolists |> Maybe.map .name |> Maybe.withDefault ""
    in
    if (Dict.get (Tuple.first model.comparableId) todolists |> Maybe.map .templateId) /= (Dict.get (Tuple.second model.comparableId) todolists |> Maybe.map .templateId) then
        text "The todolists dont use the same template and cannot be compared"

    else
        div []
            [ div [ class "row" ]
                [ div [ class "col-6 text-center" ] [ text template1Name ]
                , div [ class "col-6 text-center" ] [ text template2Name ]
                ]
            , div [ class "row mb-4" ]
                (List.map
                    (\item ->
                        div [ class "col-12" ]
                            [ div [ class "row flex-column " ]
                                [ div [ class "text-center text-muted" ] [ text item.name ]
                                , div [ class "row mx-2 bg-light comparison__item" ]
                                    [ div
                                        [ class "col-6 text-center p-3 comparison__item__left"
                                        , classList [ ( "bg-success", item.completed1 ), ( "bg-warning", not item.completed1 ) ]
                                        ]
                                        [ boolToHtml item.completed1 ]
                                    , div
                                        [ class "col-6 text-center p-3 comparison__item__right "
                                        , classList [ ( "bg-success", item.completed2 ), ( "bg-warning", not item.completed2 ) ]
                                        ]
                                        [ boolToHtml item.completed2 ]
                                    ]
                                ]
                            ]
                    )
                    all
                )
            ]


boolToHtml bool =
    if bool then
        Icon.view [ style "color" "#fff" ] Icon.Pass

    else
        Icon.view [] Icon.Fail



-- MISC


getKey : Model -> Nav.Key
getKey =
    .key


encoder : Template -> ActualList -> Model -> Json.Encode.Value
encoder template actualList model =
    Json.Encode.object
        [ ( "type", Json.Encode.string "Compare" )
        , ( "model"
          , Json.Encode.object
                [ ( "comparableId"
                  , Json.Encode.Extra.tuple
                        Json.Encode.string
                        Json.Encode.string
                        model.comparableId
                  )
                ]
          )
        , ( "template", Template.encoder template )
        , ( "todoList", ActualList.encoder actualList )
        ]


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "model"
        (Json.Decode.map2 Model
            (Json.Decode.field "comparableId" (Json.Decode.Extra.tuple Json.Decode.string Json.Decode.string))
            (Json.Decode.succeed key)
        )
