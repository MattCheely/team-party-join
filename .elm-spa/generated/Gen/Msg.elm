module Gen.Msg exposing (Msg(..))

import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Pages.Home_
import Pages.Login
import Pages.NotFound


type Msg
    = Home_ Pages.Home_.Msg
    | Login Pages.Login.Msg

