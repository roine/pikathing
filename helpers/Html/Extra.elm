module Html.Extra exposing (onEnter)

import Html
import Html.Events exposing (on)
import Json.Decode


onEnter : msg -> Html.Attribute msg
onEnter tagger =
    on "keydown"
        (Json.Decode.field "key" Json.Decode.string
            |> Json.Decode.andThen
                (\key ->
                    if key == "Enter" then
                        Json.Decode.succeed tagger

                    else
                        Json.Decode.fail "Other than Enter"
                )
        )
