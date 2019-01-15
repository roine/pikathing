module Route exposing (Page(..), SubTemplatePage(..), fromUrl, parser, toString)

import Maybe exposing (Maybe(..))
import Url
import Url.Parser as Parser exposing ((</>), Parser, s)


type Page
    = Home
    | Template SubTemplatePage


type SubTemplatePage
    = Add


fromUrl : Url.Url -> Maybe Page
fromUrl url =
    -- Treat fragment as path for convenience
    --    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    url |> Parser.parse parser


parser : Parser (Page -> b) b
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map (Template Add) (s "template" </> s "add")
        ]


toString : Page -> String
toString route =
    case route of
        Home ->
            "/"

        Template Add ->
            "/template/add"
