module Icon exposing (Icon(..), fromString, toString, view)

import Html exposing (Html, i)
import Html.Attributes exposing (class)


type Icon
    = Home
    | Laptop
    | Car
    | Book
    | Bed
    | Cross
    | Briefcase
    | Trash
    | Pass
    | Fail
    | Tv
    | Mobile
    | Tablet


fromString : String -> Maybe Icon
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

        "times" ->
            Just Cross

        "briefcase" ->
            Just Briefcase

        "trash" ->
            Just Trash

        "times-circle" ->
            Just Fail

        "check-circle" ->
            Just Pass

        "tv" ->
            Just Tv

        "mobile-alt" ->
            Just Mobile

        "tablet-alt" ->
            Just Tablet

        _ ->
            Nothing



-- String have to match FA classes


toString : Icon -> String
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

        Cross ->
            "times"

        Briefcase ->
            "briefcase"

        Trash ->
            "trash"

        Pass ->
            "check-circle"

        Fail ->
            "times-circle"

        Tv ->
            "tv"

        Mobile ->
            "mobile-alt"

        Tablet ->
            "tablet-alt"


view : List (Html.Attribute msg) -> Icon -> Html msg
view attrs icon =
    i ([ class ("fa fa-" ++ toString icon) ] ++ attrs) []
