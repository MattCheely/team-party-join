module Evergreen.V3.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V3.Api.Steam
import Evergreen.V3.Api.Steam.PlayerService
import Evergreen.V3.Api.Steam.SteamUser
import Evergreen.V3.Bridge
import Evergreen.V3.Gen.Pages
import Evergreen.V3.Shared
import Lamdera
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V3.Shared.Model
    , page : Evergreen.V3.Gen.Pages.Model
    }


type alias Session =
    { user : Evergreen.V3.Api.Steam.SteamUser.PlayerSummary
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V3.Shared.Msg
    | Page Evergreen.V3.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V3.Bridge.ToBackend


type BackendMsg
    = GotUserInfo_Shared Lamdera.SessionId Lamdera.ClientId (Result Evergreen.V3.Api.Steam.Error Evergreen.V3.Api.Steam.SteamUser.PlayerSummary)
    | GotFriendsList_Home Lamdera.ClientId (Result Evergreen.V3.Api.Steam.Error (List Evergreen.V3.Api.Steam.SteamUser.PlayerSummary))
    | GotGames_Home Lamdera.ClientId Evergreen.V3.Api.Steam.SteamId (Result Evergreen.V3.Api.Steam.Error Evergreen.V3.Api.Steam.PlayerService.GameList)
    | CheckSession Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession Evergreen.V3.Api.Steam.SteamUser.PlayerSummary
    | PageMsg Evergreen.V3.Gen.Pages.Msg
    | SharedMsg Evergreen.V3.Shared.Msg
    | NoOpToFrontend
