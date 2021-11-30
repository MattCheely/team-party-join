module Evergreen.V2.Gen.Msg exposing (..)

import Evergreen.V2.Pages.Home_
import Evergreen.V2.Pages.Login


type Msg
    = Home_ Evergreen.V2.Pages.Home_.Msg
    | Login Evergreen.V2.Pages.Login.Msg
