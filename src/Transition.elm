module Transition exposing (State(..), Status(..), getTime, isActive, isInitial, mapTime, nextState)


type alias Time =
    Float


type Status
    = Enter State Time
    | Appear State Time
    | Leave State Time


type State
    = Initial
    | Active
    | Over


mapTime fn status =
    case status of
        Enter state time ->
            Enter state (fn time)

        Appear state time ->
            Appear state (fn time)

        Leave state time ->
            Leave state (fn time)


getTime status =
    case status of
        Enter state time ->
            time

        Appear state time ->
            time

        Leave state time ->
            time


nextState status =
    case status of
        Enter Initial time ->
            Just (Enter Active time)

        Enter Active time ->
            Just (Enter Over time)

        Enter Over time ->
            Nothing

        Appear Initial time ->
            Just (Appear Active time)

        Appear Active time ->
            Just (Appear Over time)

        Appear Over time ->
            Nothing

        Leave Initial time ->
            Just (Leave Active time)

        Leave Active time ->
            Just (Leave Over time)

        Leave Over time ->
            Nothing


isActive status =
    case status of
        Enter Initial time ->
            False

        Enter Active time ->
            True

        Enter Over time ->
            False

        Appear Initial time ->
            False

        Appear Active time ->
            True

        Appear Over time ->
            False

        Leave Initial time ->
            False

        Leave Active time ->
            True

        Leave Over time ->
            False


isInitial status =
    case status of
        Enter Initial time ->
            True

        Enter Active time ->
            False

        Enter Over time ->
            False

        Appear Initial time ->
            True

        Appear Active time ->
            False

        Appear Over time ->
            False

        Leave Initial time ->
            True

        Leave Active time ->
            False

        Leave Over time ->
            False
