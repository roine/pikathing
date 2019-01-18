module Colour.Extra exposing (mapRgba, mix)

import Color exposing (Color, fromRgba, rgb, rgba, toRgba)


mapRgba : ({ red : Float, green : Float, blue : Float, alpha : Float } -> { red : Float, green : Float, blue : Float, alpha : Float }) -> Color -> Color
mapRgba fn colour =
    toRgba colour |> fn |> fromRgba


mix : Float -> Color -> Color -> Color
mix p color1 color2 =
    let
        rgba1 =
            toRgba color1

        rgba2 =
            toRgba color2

        w =
            p * 2 - 1

        a =
            rgba1.alpha - rgba2.alpha

        w1 =
            if w * a == -1 then
                w

            else
                (((w + a) / (1 + w * a)) + 1) / 2.0

        w2 =
            1 - w1

        r =
            rgba1.red * w1 + rgba2.red * w2

        g =
            rgba1.green * w1 + rgba2.green * w2

        b =
            rgba1.blue * w1 + rgba2.blue * w2

        alpha =
            rgba1.alpha * p + rgba2.alpha * (1 - p)
    in
    rgba r g b alpha
