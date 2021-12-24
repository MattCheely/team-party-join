module Evergreen.V7.Gen.Msg exposing (..)

import Evergreen.V7.Pages.Home_
import Evergreen.V7.Pages.Login
import Evergreen.V7.Pages.SharedGames.SteamIds_


type Msg
    = Home_ Evergreen.V7.Pages.Home_.Msg
    | Login Evergreen.V7.Pages.Login.Msg
    | SharedGames__SteamIds_ Evergreen.V7.Pages.SharedGames.SteamIds_.Msg
