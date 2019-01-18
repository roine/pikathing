module Icon exposing (Icon(..), fromString, toString, view)

import Html exposing (i)
import Html.Attributes exposing (class)


type Icon
    = Home
    | Laptop
    | Car
    | Book
    | Bed


fromString str =
    case str of
        "home" ->
            Just Home

        "laptop" ->
            Just Laptop

        "car" ->
            Just Car

        "book" ->
            Just Book

        "bed" ->
            Just Bed

        _ ->
            Nothing



-- String have to match FA classes


toString icon =
    case icon of
        Home ->
            "home"

        Laptop ->
            "laptop"

        Car ->
            "car"

        Book ->
            "book"

        Bed ->
            "bed"


view attrs icon =
    i ([ class ("fa fa-" ++ toString icon) ] ++ attrs) []
