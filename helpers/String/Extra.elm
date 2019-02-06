module String.Extra exposing (keepLeft, keepRight)


keepLeft : Int -> String -> String
keepLeft len str =
    if String.length str <= len then
        str

    else
        String.dropRight (String.length str - len) str


keepRight : Int -> String -> String
keepRight len str =
    if String.length str <= len then
        str

    else
        String.dropLeft (String.length str - len) str
