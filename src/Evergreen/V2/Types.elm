module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V2.Api.Steam
import Evergreen.V2.Api.Steam.PlayerService
import Evergreen.V2.Api.Steam.SteamUser
import Evergreen.V2.Bridge
import Evergreen.V2.Gen.Pages
import Evergreen.V2.Shared
import Lamdera
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V2.Shared.Model
    , page : Evergreen.V2.Gen.Pages.Model
    }


type alias Session =
    { user : Evergreen.V2.Api.Steam.SteamUser.PlayerSummary
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V2.Shared.Msg
    | Page Evergreen.V2.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V2.Bridge.ToBackend


type BackendMsg
    = GotGames_Home Lamdera.ClientId Evergreen.V2.Api.Steam.SteamId (Result Evergreen.V2.Api.Steam.Error Evergreen.V2.Api.Steam.PlayerService.GameList)
    | GotUserInfo_Shared Lamdera.SessionId Lamdera.ClientId (Result Evergreen.V2.Api.Steam.Error Evergreen.V2.Api.Steam.SteamUser.PlayerSummary)
    | CheckSession Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession Evergreen.V2.Api.Steam.SteamUser.PlayerSummary
    | PageMsg Evergreen.V2.Gen.Pages.Msg
    | SharedMsg Evergreen.V2.Shared.Msg
    | NoOpToFrontend
