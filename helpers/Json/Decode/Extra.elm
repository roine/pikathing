module Json.Decode.Extra exposing (tuple)

import Json.Decode exposing (Decoder, field, map2)


tuple : Decoder a -> Decoder b -> Decoder ( a, b )
tuple type1 type2 =
    map2 Tuple.pair
        (field "key" type1)
        (field "value" type2)
