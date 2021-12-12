module Backend exposing (..)

import Api.Data as Data exposing (Data(..))
import Api.Steam.PlayerService as PlayerService
import Api.Steam.SteamUser as SteamUser exposing (FriendInfo, PlayerSummary)
import Bridge exposing (..)
import Dict
import Dict.Extra as Dict
import Gen.Msg
import Lamdera exposing (..)
import Pages.Home_
import Pages.SharedGames.SteamIds_
import Shared
import Types exposing (BackendModel, BackendMsg(..), FrontendMsg(..), Session, ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> onConnect CheckSession
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { sessions = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        GotFriendsList_Home cid response ->
            ( model
            , sendToFrontend cid
                (PageMsg
                    (Gen.Msg.Home_
                        (Pages.Home_.GotFriends
                            (Data.fromResult response)
                        )
                    )
                )
            )

        GotGames_SharedGames cid steamId response ->
            ( model
            , sendToFrontend cid
                (PageMsg
                    (Gen.Msg.SharedGames__SteamIds_
                        (Pages.SharedGames.SteamIds_.GotGames steamId
                            (Data.fromResult response)
                        )
                    )
                )
            )

        GotPlayerSummaries_SharedGames cid response ->
            ( model
            , sendToFrontend cid
                (PageMsg
                    (Gen.Msg.SharedGames__SteamIds_
                        (Pages.SharedGames.SteamIds_.GotPlayerSummaries (Data.fromResult response))
                    )
                )
            )

        GotUserInfo_Shared sid cid response ->
            ( case response of
                Err _ ->
                    model

                Ok user ->
                    { model
                        | sessions =
                            Dict.update sid (setSessionUser user) model.sessions
                    }
            , sendToFrontend cid (SharedMsg (Shared.UserResult response))
            )

        CheckSession sid cid ->
            model
                |> getSessionUser sid
                |> Maybe.map (\user -> ( model, sendToFrontend cid (ActiveSession user) ))
                |> Maybe.withDefault ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        send v =
            ( model, send_ v )

        send_ v =
            sendToFrontend clientId v
    in
    case msg of
        GetFriendsList_Home steamId ->
            ( model, SteamUser.getFriendListDetails (GotFriendsList_Home clientId) steamId )

        LookupGames_SharedGames steamId ->
            ( model
            , PlayerService.getOwnedGames
                (GotGames_SharedGames clientId steamId)
                { steamId = steamId }
            )

        GetPlayerSummaries_SharedGames steamIds ->
            ( model, SteamUser.getPlayerSummaries (GotPlayerSummaries_SharedGames clientId) steamIds )

        GetUserInfo_Shared steamId ->
            ( model, SteamUser.getPlayerSummary (GotUserInfo_Shared sessionId clientId) steamId )

        SignedOut ->
            ( { model | sessions = model.sessions |> Dict.remove sessionId }, Cmd.none )


getSessionUser : SessionId -> Model -> Maybe PlayerSummary
getSessionUser sid model =
    model.sessions
        |> Dict.get sid
        |> Maybe.map .user


setSessionUser : PlayerSummary -> Maybe Session -> Maybe Session
setSessionUser player maybeSession =
    case maybeSession of
        Just session ->
            Just { session | user = player }

        Nothing ->
            Just { user = player }
