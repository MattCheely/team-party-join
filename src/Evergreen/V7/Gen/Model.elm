module Evergreen.V7.Gen.Model exposing (..)

import Evergreen.V7.Gen.Params.Home_
import Evergreen.V7.Gen.Params.Login
import Evergreen.V7.Gen.Params.NotFound
import Evergreen.V7.Gen.Params.SharedGames.SteamIds_
import Evergreen.V7.Pages.Home_
import Evergreen.V7.Pages.Login
import Evergreen.V7.Pages.SharedGames.SteamIds_


type Model
    = Redirecting_
    | Home_ Evergreen.V7.Gen.Params.Home_.Params Evergreen.V7.Pages.Home_.Model
    | Login Evergreen.V7.Gen.Params.Login.Params Evergreen.V7.Pages.Login.Model
    | NotFound Evergreen.V7.Gen.Params.NotFound.Params
    | SharedGames__SteamIds_ Evergreen.V7.Gen.Params.SharedGames.SteamIds_.Params Evergreen.V7.Pages.SharedGames.SteamIds_.Model
