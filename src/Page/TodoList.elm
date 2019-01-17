module Page.TodoList exposing (Model(..), Msg, decoder, encoder, getKey, init, update, view)

import ActualList
import Browser.Navigation as Nav
import Html exposing (text)
import Json.Decode
import Json.Encode
import Page.TodoList.View as TodoListView
import Route
import Template


type Model
    = ViewModel TodoListView.Model


init key template route =
    case route of
        Route.ViewPage id ->
            TodoListView.init key id template
                |> Tuple.mapBoth ViewModel (Cmd.map ViewMsg)

        _ ->
            TodoListView.init key "" template
                |> Tuple.mapBoth ViewModel (Cmd.map ViewMsg)


type Msg
    = ViewMsg TodoListView.Msg


update msg template actualList model =
    case ( msg, model ) of
        ( ViewMsg subMsg, ViewModel m ) ->
            let
                ( newActualList, newModel, cmd ) =
                    TodoListView.update subMsg template actualList m
            in
            { template = template, actualList = newActualList, model = ViewModel newModel, cmd = Cmd.map ViewMsg cmd }


view templates actualList model =
    case model of
        ViewModel m ->
            Html.map ViewMsg (TodoListView.view templates actualList m)


getKey : Model -> Nav.Key
getKey model =
    case model of
        ViewModel m ->
            TodoListView.getKey m


encoder template actualList model =
    let
        sharedEncoder =
            [ ( "type", Json.Encode.string "TodoList" )
            , ( "template", Template.encoder template )
            , ( "todoList", ActualList.encoder actualList )
            ]
    in
    case model of
        ViewModel viewModel ->
            sharedEncoder
                |> (++)
                    [ ( "subType", Json.Encode.string "View" )
                    , ( "model", TodoListView.encoder viewModel )
                    ]
                |> Json.Encode.object


decoder : Nav.Key -> Json.Decode.Decoder Model
decoder key =
    Json.Decode.field "subType" Json.Decode.string
        |> Json.Decode.andThen
            (\type_ ->
                case type_ of
                    "View" ->
                        Json.Decode.map ViewModel (Json.Decode.field "model" (TodoListView.decoder key))

                    otherwise ->
                        Json.Decode.fail ("Tried decoding " ++ otherwise)
            )
