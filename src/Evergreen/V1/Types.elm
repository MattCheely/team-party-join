module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.Api.Steam
import Evergreen.V1.Api.Steam.PlayerService
import Evergreen.V1.Api.Steam.SteamUser
import Evergreen.V1.Bridge
import Evergreen.V1.Gen.Pages
import Evergreen.V1.Shared
import Lamdera
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V1.Shared.Model
    , page : Evergreen.V1.Gen.Pages.Model
    }


type alias Session =
    { user : Evergreen.V1.Api.Steam.SteamUser.PlayerSummary
    }


type alias BackendModel =
    { sessions : Dict.Dict Lamdera.SessionId Session
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V1.Shared.Msg
    | Page Evergreen.V1.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V1.Bridge.ToBackend


type BackendMsg
    = GotGames_Home Lamdera.ClientId Evergreen.V1.Api.Steam.SteamId (Result Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.PlayerService.GameList)
    | GotUserInfo_Shared Lamdera.SessionId Lamdera.ClientId (Result Evergreen.V1.Api.Steam.Error Evergreen.V1.Api.Steam.SteamUser.PlayerSummary)
    | CheckSession Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = ActiveSession Evergreen.V1.Api.Steam.SteamUser.PlayerSummary
    | PageMsg Evergreen.V1.Gen.Pages.Msg
    | SharedMsg Evergreen.V1.Shared.Msg
    | NoOpToFrontend
