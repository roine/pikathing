module Template exposing (Model, Template)


type alias Model =
    List Template


type alias Template =
    { id : String, name : String }
