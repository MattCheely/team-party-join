module Api.Steam exposing
    ( Error(..)
    , QueryParameter
    , boolParam
    , intParam
    , stringParam
    , translateError
    , urlFor
    )

import Env exposing (steamApiKey)
import Http exposing (Error(..))
import Url.Builder as Builder exposing (QueryParameter, crossOrigin)


type Error
    = AccessDenied
    | TooManyRequests
    | InternalError


type alias QueryParameter =
    Builder.QueryParameter


urlFor : String -> String -> List QueryParameter -> String
urlFor interface method params =
    crossOrigin "https://api.steampowered.com"
        [ interface, method, "v1" ]
        (Builder.string "key" steamApiKey :: params)


boolParam : String -> Bool -> QueryParameter
boolParam key value =
    case value of
        True ->
            Builder.string key "true"

        False ->
            Builder.string key "false"


intParam : String -> Int -> QueryParameter
intParam =
    Builder.int


stringParam : String -> String -> QueryParameter
stringParam =
    Builder.string


translateError : Http.Error -> Error
translateError httpError =
    case httpError of
        BadStatus 401 ->
            AccessDenied

        BadStatus 403 ->
            AccessDenied

        BadStatus 429 ->
            TooManyRequests

        _ ->
            InternalError
