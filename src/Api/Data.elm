module Api.Data exposing (Data(..), fromResult, map, toMaybe)


type Data error value
    = NotAsked
    | Loading
    | Failure error
    | Success value


map : (a -> b) -> Data x a -> Data x b
map fn data =
    case data of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure reason ->
            Failure reason

        Success value ->
            Success (fn value)


fromResult : Result error value -> Data error value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err err ->
            Failure err


toMaybe : Data error value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing
