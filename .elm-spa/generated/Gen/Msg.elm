module Gen.Msg exposing (Msg(..))

import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Gen.Params.SharedGames.SteamIds_
import Pages.Home_
import Pages.Login
import Pages.NotFound
import Pages.SharedGames.SteamIds_


type Msg
    = Home_ Pages.Home_.Msg
    | Login Pages.Login.Msg
    | SharedGames__SteamIds_ Pages.SharedGames.SteamIds_.Msg

