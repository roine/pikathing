module Page.Template.View exposing (Model, Msg, decoder, encoder, getKey, init, update, view)

import Browser.Navigation as Nav
import Html exposing (button, div, input, text)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Json.Encode


type alias Model =
    { key : Nav.Key, id : String, name : String }


init key id =
    ( { key = key, id = id, name = "" }, Cmd.none )


type Msg
    = UpdateName String
    | MakeCopy


update msg actualList model =
    case msg of
        UpdateName newName ->
            ( actualList, { model | name = newName }, Cmd.none )

        MakeCopy ->
            ( actualList, model, Cmd.none )


view model template actualList =
    div []
        [ input [ onInput UpdateName, value model.name ] []
        , button [ onClick MakeCopy ] [ text "Make a new copy" ]
        ]


encoder model =
    Json.Encode.object [ ( "id", Json.Encode.string model.id ), ( "name", Json.Encode.string model.name ) ]


decoder key =
    Json.Decode.map3 Model (Json.Decode.succeed key) (Json.Decode.field "id" Json.Decode.string) (Json.Decode.field "name" Json.Decode.string)


getKey =
    .key
