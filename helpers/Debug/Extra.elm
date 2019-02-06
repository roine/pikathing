module Debug.Extra exposing (viewModel)

import Html exposing (Html, p, pre, text)
import Html.Attributes exposing (style)


quote =
    "\""


indentChars =
    "[{("


outdentChars =
    "}])"


newLineChars =
    ","


uniqueHead =
    "##FORMAT##"


incr =
    20


viewModel : a -> Html msg
viewModel model =
    let
        lines =
            model
                |> Debug.toString
                |> (\m ->
                        "("
                            ++ m
                            ++ ")"
                            |> formatString False 0
                            |> String.split uniqueHead
                   )
    in
    pre [] <| List.map viewLine lines


viewLine : String -> Html msg
viewLine lineStr =
    let
        ( indent, lineTxt ) =
            splitLine lineStr
    in
    p
        [ style "paddingLeft" (px indent)
        , style "marginTop" "0px"
        , style "marginBottom" "0px"
        ]
        [ text lineTxt ]


px : Int -> String
px int =
    String.fromInt int
        ++ "px"


formatString : Bool -> Int -> String -> String
formatString isInQuotes indent str =
    case String.left 1 str of
        "" ->
            ""

        firstChar ->
            if isInQuotes then
                if firstChar == quote then
                    firstChar
                        ++ formatString (not isInQuotes) indent (String.dropLeft 1 str)

                else
                    firstChar
                        ++ formatString isInQuotes indent (String.dropLeft 1 str)

            else if String.contains firstChar newLineChars then
                uniqueHead
                    ++ pad indent
                    ++ firstChar
                    ++ formatString isInQuotes indent (String.dropLeft 1 str)

            else if String.contains firstChar indentChars then
                uniqueHead
                    ++ pad (indent + incr)
                    ++ firstChar
                    ++ formatString isInQuotes (indent + incr) (String.dropLeft 1 str)

            else if String.contains firstChar outdentChars then
                firstChar
                    ++ uniqueHead
                    ++ pad (indent - incr)
                    ++ formatString isInQuotes (indent - incr) (String.dropLeft 1 str)

            else if firstChar == quote then
                firstChar
                    ++ formatString (not isInQuotes) indent (String.dropLeft 1 str)

            else
                firstChar
                    ++ formatString isInQuotes indent (String.dropLeft 1 str)


pad : Int -> String
pad indent =
    String.padLeft 5 '0' <| Debug.toString indent


splitLine : String -> ( Int, String )
splitLine line =
    let
        indent =
            String.left 5 line
                |> String.toInt
                |> Maybe.withDefault 0

        newLine =
            String.dropLeft 5 line
    in
    ( indent, newLine )
