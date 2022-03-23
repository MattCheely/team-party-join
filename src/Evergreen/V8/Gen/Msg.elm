module Evergreen.V8.Gen.Msg exposing (..)

import Evergreen.V8.Pages.Home_
import Evergreen.V8.Pages.Login
import Evergreen.V8.Pages.SharedGames.SteamIds_


type Msg
    = Home_ Evergreen.V8.Pages.Home_.Msg
    | Login Evergreen.V8.Pages.Login.Msg
    | SharedGames__SteamIds_ Evergreen.V8.Pages.SharedGames.SteamIds_.Msg
