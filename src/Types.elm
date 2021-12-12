module Types exposing (..)

{-| This module (along with Bridge.elm) holds the core types for our Lamdera app
In most Elm apps it doesn't particularly matter where the types go, but for
Lamdera to bootstrap the platform effectively, it needs to know where to find
all these types.
-}

import Api.Steam as Steam exposing (SteamId)
import Api.Steam.PlayerService exposing (GameList)
import Api.Steam.SteamUser exposing (PlayerSummary)
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
      -- Use when you don't care about the result of a Cmd (fire-and-forget)
    | Noop


type alias ToBackend =
    Bridge.ToBackend


{-| Messages sent by the backend to itself. By convention, if the message is
processing a request for a specific page, it has the format `Event_PageName`
-}
type BackendMsg
    = GotUserInfo_Shared SessionId ClientId (Result Steam.Error PlayerSummary)
    | GotFriendsList_Home ClientId (Result Steam.Error (List PlayerSummary))
    | GotGames_SharedGames ClientId SteamId (Result Steam.Error GameList)
    | GotPlayerSummaries_SharedGames ClientId (Result Steam.Error (List PlayerSummary))
    | CheckSession SessionId ClientId


{-| Messages sent by the backend to the frontend. When targeting a specific page
the backend can just send a `PageMsg` and construct the relevant event from the
generated elm-spa page types
-}
type ToFrontend
    = ActiveSession PlayerSummary
    | PageMsg Pages.Msg
    | SharedMsg Shared.Msg
