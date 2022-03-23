module Evergreen.V8.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V8.Api.Steam
import Evergreen.V8.Api.Steam.PlayerService
import Evergreen.V8.Api.Steam.SteamUser
import Evergreen.V8.Bridge
import Evergreen.V8.Gen.Pages
import Evergreen.V8.Shared
import Lamdera
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V8.Shared.Model
    , page : Evergreen.V8.Gen.Pages.Model
    }


type alias Session =
    { user : Evergreen.V8.Api.Steam.SteamUser.PlayerSummary
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V8.Shared.Msg
    | Page Evergreen.V8.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V8.Bridge.ToBackend


type BackendMsg
    = GotUserInfo_Shared Lamdera.SessionId Lamdera.ClientId (Result Evergreen.V8.Api.Steam.Error Evergreen.V8.Api.Steam.SteamUser.PlayerSummary)
    | GotFriendsList_Home Lamdera.ClientId (Result Evergreen.V8.Api.Steam.Error (List Evergreen.V8.Api.Steam.SteamUser.PlayerSummary))
    | GotGames_SharedGames Lamdera.ClientId Evergreen.V8.Api.Steam.SteamId (Result Evergreen.V8.Api.Steam.Error Evergreen.V8.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries_SharedGames Lamdera.ClientId (Result Evergreen.V8.Api.Steam.Error (List Evergreen.V8.Api.Steam.SteamUser.PlayerSummary))
    | CheckSession Lamdera.SessionId Lamdera.ClientId


type ToFrontend
    = ActiveSession Evergreen.V8.Api.Steam.SteamUser.PlayerSummary
    | PageMsg Evergreen.V8.Gen.Pages.Msg
    | SharedMsg Evergreen.V8.Shared.Msg
