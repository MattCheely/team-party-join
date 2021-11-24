module Types exposing (..)

import Api.Steam as Steam
import Api.Steam.PlayerService exposing (GameList)
import Api.User exposing (User, UserFull, UserId)
import Bridge
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Gen.Pages as Pages
import Lamdera exposing (ClientId, SessionId)
import Shared
import Time
import Url exposing (Url)


type alias FrontendModel =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , page : Pages.Model
    }


type alias BackendModel =
    { sessions : Dict SessionId Session
    , users : Dict Int UserFull
    }


type alias Session =
    { userId : Int, expires : Time.Posix }


type FrontendMsg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg
    | Noop


type alias ToBackend =
    Bridge.ToBackend


type BackendMsg
    = GotGames_Home ClientId (Result Steam.Error GameList)
      -- Legacy lamdera-realworld messages
    | CheckSession SessionId ClientId
    | RenewSession UserId SessionId ClientId Time.Posix
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession User
    | PageMsg Pages.Msg
    | NoOpToFrontend
