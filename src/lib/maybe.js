// @flow

type JustType<T> = {
  map: (T => T) => JustType<T>
}

type NothingType<T> = {
  map: (any => any) => NothingType<T>
}

export type MaybeType<T> =
  | JustType<T>
  | NothingType<T>

function Just (a: any) {
  function map (fn: (any => any)) {
    return Just(fn(a))
  }

  return {
    map,
  }
}

function Nothing () {
  function map (fn: (any => any)) {
    return Nothing()
  }

  return {map}
}

export default {Just, Nothing}