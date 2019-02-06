module Json.Encode.Extra exposing (tuple)

import Json.Encode exposing (Value, object)


tuple : (a -> Value) -> (b -> Value) -> ( a, b ) -> Value
tuple type1 type2 tup =
    object
        [ ( "key", type1 (Tuple.first tup) )
        , ( "value", type2 (Tuple.second tup) )
        ]
