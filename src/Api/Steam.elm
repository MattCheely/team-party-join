module Api.Steam exposing
    ( Error(..)
    , QueryParameter
    , SteamId
    , boolParam
    , expectJson
    , intParam
    , stringParam
    , urlFor
    )

import Env exposing (steamApiKey)
import Http exposing (Error(..))
import Json.Decode exposing (Decoder)
import Url.Builder as Builder exposing (QueryParameter, crossOrigin)


type alias SteamId =
    String


type Error
    = AccessDenied
    | TooManyRequests
    | InternalError


type alias QueryParameter =
    Builder.QueryParameter


urlFor : List String -> List QueryParameter -> String
urlFor path params =
    crossOrigin "https://api.steampowered.com"
        path
        (Builder.string "key" steamApiKey :: params)


expectJson : (Result Error a -> msg) -> Decoder a -> Http.Expect msg
expectJson msg decoder =
    Http.expectJson
        (Result.mapError translateError >> msg)
        decoder


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

        other ->
            InternalError
