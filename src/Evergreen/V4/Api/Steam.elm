module Evergreen.V4.Api.Steam exposing (..)


type alias SteamId =
    String


type Error
    = AccessDenied
    | TooManyRequests
    | InternalError
