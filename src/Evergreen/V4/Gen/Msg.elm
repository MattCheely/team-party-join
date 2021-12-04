module Evergreen.V4.Gen.Msg exposing (..)

import Evergreen.V4.Pages.Home_
import Evergreen.V4.Pages.Login
import Evergreen.V4.Pages.SharedGames.SteamIds_


type Msg
    = Home_ Evergreen.V4.Pages.Home_.Msg
    | Login Evergreen.V4.Pages.Login.Msg
    | SharedGames__SteamIds_ Evergreen.V4.Pages.SharedGames.SteamIds_.Msg
