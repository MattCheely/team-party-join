module Evergreen.V5.Gen.Msg exposing (..)

import Evergreen.V5.Pages.Home_
import Evergreen.V5.Pages.Login
import Evergreen.V5.Pages.SharedGames.SteamIds_


type Msg
    = Home_ Evergreen.V5.Pages.Home_.Msg
    | Login Evergreen.V5.Pages.Login.Msg
    | SharedGames__SteamIds_ Evergreen.V5.Pages.SharedGames.SteamIds_.Msg
