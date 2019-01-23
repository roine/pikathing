module Transition exposing (Model, State(..), Status(..), add, decoder, init, subscriptions, toClass, update)

import Browser.Events exposing (onAnimationFrame, onAnimationFrameDelta)
import Dict exposing (Dict)
import Dict.Extra
import Json.Decode
import Time exposing (Posix)



{-
   Future
      Get rid of css animation instead use style change with elm-community/easing-functions

       How it'll work
       get a list of transition progression percentage
       the index / length is the percentage of time elapsed
       ie:
       [0.1 0.1 0.2 0.4 0.5 0.8 0.8 1]
       we want to move from 0 to 10
       at index 4 we are 50% (8 / 4) done in the animation duration
       and we are 40% (0.4) done in the transition
       we'll need to store when the animation started to know percentage achieved then access index of animation progression

-}


type alias Model =
    { transitions : Dict String { status : Status, start : Posix }, time : Posix }


init : Model
init =
    { transitions = Dict.empty, time = Time.millisToPosix 0 }


type alias Time =
    Int


type Status
    = Enter State Time
    | Appear State Time
    | Leave State Time


type State
    = Initial
    | Active
    | Over


mapTime : (Time -> Time) -> Status -> Status
mapTime fn status =
    case status of
        Enter state time ->
            Enter state (fn time)

        Appear state time ->
            Appear state (fn time)

        Leave state time ->
            Leave state (fn time)


getTime : Status -> Time
getTime status =
    case status of
        Enter state time ->
            time

        Appear state time ->
            time

        Leave state time ->
            time


nextState : Status -> Maybe Status
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


isActive : Status -> Bool
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


isInitial : Status -> Bool
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


toClass : String -> Status -> String
toClass prefix transition =
    case transition of
        Enter Initial _ ->
            prefix ++ "-enter"

        Enter Active _ ->
            prefix ++ "-enter " ++ prefix ++ "-enter-active"

        Enter Over _ ->
            ""

        Appear Initial _ ->
            prefix ++ "-appear"

        Appear Active _ ->
            prefix ++ "-appear " ++ prefix ++ "-appear-active"

        Appear Over _ ->
            ""

        Leave Initial _ ->
            prefix ++ "-leave"

        Leave Active _ ->
            prefix ++ "-leave " ++ prefix ++ "-leave-active"

        Leave Over _ ->
            ""


update : Posix -> Model -> Model
update now model =
    { model
        | transitions =
            Dict.Extra.filterMap
                (\key transition ->
                    if isActive transition.status then
                        if Time.posixToMillis now >= Time.posixToMillis transition.start + getTime transition.status + 30 then
                            Maybe.map (\status -> { transition | status = status }) (nextState transition.status)

                        else
                            Just transition

                    else if isInitial transition.status && Time.posixToMillis now <= (Time.posixToMillis transition.start + 30) then
                        -- we need to keep the initial for one frame otherwise it won't animate
                        Just transition

                    else
                        Maybe.map (\status -> { transition | status = status }) (nextState transition.status)
                )
                model.transitions
                |> Debug.log "transitions"
        , time = now
    }


add : String -> Status -> Model -> Model
add id transition model =
    { model | transitions = Dict.insert id { status = transition, start = model.time } model.transitions }


subscriptions : Model -> (Posix -> msg) -> Sub msg
subscriptions model tagger =
    onAnimationFrame tagger


decoder =
    Json.Decode.succeed init
