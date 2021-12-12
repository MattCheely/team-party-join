module Bridge exposing (..)

{-| This file holds the type definition for messages passed from the front-end
to the back-end. Without getting into too much detail, keeping these in a
separate file avoids circular module dependencies which would otherwise be
generated when using tools & patterns like elm-spa. Circular dependencies are
not allowed by the Elm complier.
-}

import Api.Steam exposing (SteamId)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


{-| Messages sent by the frontend to the backend. By convention, if the page
needs the response directed back to it, the message has the format
`RequestedAction_PageName`
-}
type ToBackend
    = LookupGames_SharedGames SteamId
    | GetFriendsList_Home SteamId
    | GetUserInfo_Shared SteamId
    | GetPlayerSummaries_SharedGames (List SteamId)
    | SignedOut
