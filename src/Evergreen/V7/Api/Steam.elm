module Evergreen.V7.Api.Steam exposing (..)


type alias SteamId =
    String


type Error
    = AccessDenied
    | TooManyRequests
    | InternalError
