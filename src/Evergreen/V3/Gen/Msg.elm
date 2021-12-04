module Evergreen.V3.Gen.Msg exposing (..)

import Evergreen.V3.Pages.Home_
import Evergreen.V3.Pages.Login


type Msg
    = Home_ Evergreen.V3.Pages.Home_.Msg
    | Login Evergreen.V3.Pages.Login.Msg
