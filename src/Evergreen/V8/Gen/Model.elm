module Evergreen.V8.Gen.Model exposing (..)

import Evergreen.V8.Gen.Params.Home_
import Evergreen.V8.Gen.Params.Login
import Evergreen.V8.Gen.Params.NotFound
import Evergreen.V8.Gen.Params.SharedGames.SteamIds_
import Evergreen.V8.Pages.Home_
import Evergreen.V8.Pages.Login
import Evergreen.V8.Pages.SharedGames.SteamIds_


type Model
    = Redirecting_
    | Home_ Evergreen.V8.Gen.Params.Home_.Params Evergreen.V8.Pages.Home_.Model
    | Login Evergreen.V8.Gen.Params.Login.Params Evergreen.V8.Pages.Login.Model
    | NotFound Evergreen.V8.Gen.Params.NotFound.Params
    | SharedGames__SteamIds_ Evergreen.V8.Gen.Params.SharedGames.SteamIds_.Params Evergreen.V8.Pages.SharedGames.SteamIds_.Model
