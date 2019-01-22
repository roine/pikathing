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


view : List (Html.Attribute msg) -> Icon -> Html msg
view attrs icon =
    i ([ class ("fa fa-" ++ toString icon) ] ++ attrs) []
