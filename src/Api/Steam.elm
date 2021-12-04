module Api.Steam exposing
    ( Error(..)
    , QueryParameter
    , SteamId
    , boolParam
    , expectJson
    , intParam
    , stringParam
    , taskGet
    , urlFor
    )

import Env exposing (steamApiKey)
import Http exposing (Error(..), Response(..), emptyBody)
import Json.Decode exposing (Decoder, decodeString)
import Task exposing (Task)
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


{-| Normally we don't use tasks much, but Steam has a lot of APIs where you want to
make a request and immeditately follow it up with another request to get useful data,
and we need tasks for that
-}
taskGet : { url : String, decoder : Decoder a } -> Task Error a
taskGet { url, decoder } =
    Http.task
        { method = "GET"
        , url = url
        , resolver = jsonResolver decoder
        , headers = []
        , body = emptyBody
        , timeout = Nothing
        }


jsonResolver : Decoder a -> Http.Resolver Error a
jsonResolver decoder =
    Http.stringResolver
        (\response ->
            case response of
                BadStatus_ metadata _ ->
                    Err (translateError (BadStatus metadata.statusCode))

                GoodStatus_ _ body ->
                    decodeString decoder body
                        |> Result.mapError (always InternalError)

                _ ->
                    Err InternalError
        )
