module Types exposing (..)

import Api.Steam as Steam exposing (SteamId)
import Api.Steam.PlayerService exposing (GameList)
import Api.Steam.SteamUser exposing (FriendInfo, PlayerSummary)
import Bridge
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Gen.Pages as Pages
import Lamdera exposing (ClientId, SessionId)
import Shared
import Url exposing (Url)


type alias FrontendModel =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , page : Pages.Model
    }


type alias BackendModel =
    { sessions : Dict SessionId Session
    }


type alias Session =
    { user : PlayerSummary }


type FrontendMsg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg
    | Noop


type alias ToBackend =
    Bridge.ToBackend


type BackendMsg
    = GotUserInfo_Shared SessionId ClientId (Result Steam.Error PlayerSummary)
    | GotFriendsList_Home ClientId (Result Steam.Error (List PlayerSummary))
    | GotGames_SharedGames ClientId SteamId (Result Steam.Error GameList)
    | GotPlayerSummaries_SharedGames ClientId (Result Steam.Error (List PlayerSummary))
    | CheckSession SessionId ClientId
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession PlayerSummary
    | PageMsg Pages.Msg
    | SharedMsg Shared.Msg
    | NoOpToFrontend
