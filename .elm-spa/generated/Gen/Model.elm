module Gen.Model exposing (Model(..))

import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.SharedGames.SteamIds_
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.SharedGames.SteamIds_


type Model
    = Redirecting_
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | Login Gen.Params.Login.Params Pages.Login.Model
    | NotFound Gen.Params.NotFound.Params
    | SharedGames__SteamIds_ Gen.Params.SharedGames.SteamIds_.Params Pages.SharedGames.SteamIds_.Model

