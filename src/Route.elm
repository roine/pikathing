module Route exposing (Page(..), SubTemplatePage(..), fromUrl, parser, toString)

import Maybe exposing (Maybe(..))
import Url
import Url.Parser as Parser exposing ((</>), Parser, int, s, string)


type Page
    = Home
    | Template SubTemplatePage


type SubTemplatePage
    = AddPage
    | EditPage String


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
