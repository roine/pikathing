module Route exposing (CrudPage(..), Page(..), fromUrl, parser, toString)

import Maybe exposing (Maybe(..))
import Url
import Url.Parser as Parser exposing ((</>), Parser, int, s, string)


type Page
    = Home
    | Template CrudPage
    | TodoList CrudPage
    | Compare String String


type CrudPage
    = AddPage
    | EditPage String
    | ViewPage String


fromUrl : Url.Url -> Maybe Page
fromUrl url =
    -- Treat fragment as path for convenience
    --    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    url |> Parser.parse parser


parser : Parser (Page -> b) b
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map (Template AddPage) (s "template" </> s "add")
        , Parser.map (Template << EditPage) (s "template" </> s "edit" </> string)
        , Parser.map (Template << ViewPage) (s "template" </> s "view" </> string)
        , Parser.map (TodoList << ViewPage) (s "todolist" </> s "view" </> string)
        , Parser.map Compare (s "compare" </> string </> string)
        ]


toString : Page -> String
toString route =
    case route of
        Home ->
            "/"

        Template AddPage ->
            "/template/add"

        Template (EditPage id) ->
            "/template/edit/" ++ id

        Template (ViewPage id) ->
            "/template/view/" ++ id

        TodoList (ViewPage id) ->
            "/todolist/view/" ++ id

        TodoList _ ->
            "/todolist"

        Compare id id2 ->
            "/compare/" ++ id ++ "/" ++ id2
