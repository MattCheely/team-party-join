module Evergreen.V4.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V4.Api.Steam
import Evergreen.V4.Api.Steam.PlayerService
import Evergreen.V4.Api.Steam.SteamUser
import Evergreen.V4.Bridge
import Evergreen.V4.Gen.Pages
import Evergreen.V4.Shared
import Lamdera
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V4.Shared.Model
    , page : Evergreen.V4.Gen.Pages.Model
    }


type alias Session =
    { user : Evergreen.V4.Api.Steam.SteamUser.PlayerSummary
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V4.Shared.Msg
    | Page Evergreen.V4.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V4.Bridge.ToBackend


type BackendMsg
    = GotUserInfo_Shared Lamdera.SessionId Lamdera.ClientId (Result Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.SteamUser.PlayerSummary)
    | GotFriendsList_Home Lamdera.ClientId (Result Evergreen.V4.Api.Steam.Error (List Evergreen.V4.Api.Steam.SteamUser.PlayerSummary))
    | GotGames_SharedGames Lamdera.ClientId Evergreen.V4.Api.Steam.SteamId (Result Evergreen.V4.Api.Steam.Error Evergreen.V4.Api.Steam.PlayerService.GameList)
    | GotPlayerSummaries_SharedGames Lamdera.ClientId (Result Evergreen.V4.Api.Steam.Error (List Evergreen.V4.Api.Steam.SteamUser.PlayerSummary))
    | CheckSession Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession Evergreen.V4.Api.Steam.SteamUser.PlayerSummary
    | PageMsg Evergreen.V4.Gen.Pages.Msg
    | SharedMsg Evergreen.V4.Shared.Msg
    | NoOpToFrontend
