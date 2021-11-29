module Gen.Model exposing (Model(..))

import Gen.Params.Home_
import Gen.Params.Login
import Gen.Params.NotFound
import Pages.Home_
import Pages.Login
import Pages.NotFound


type Model
    = Redirecting_
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | Login Gen.Params.Login.Params Pages.Login.Model
    | NotFound Gen.Params.NotFound.Params

