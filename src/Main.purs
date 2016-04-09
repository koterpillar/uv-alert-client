module Main where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)

import Data.Date (Now)
import Data.Time (Milliseconds(..))

import Data.Either (Either(..))

import Data.Foldable (foldl)

import Data.Foreign.Class (read)

import Data.Int (toNumber)

import Data.Maybe (Maybe(..))

import Network.HTTP.Affjax (AJAX, get)

import Pebble.Settings (SETTINGS, getOption, setOption)
import Pebble.Timeline (TIMELINE, setSubscriptions)
import Pebble.UI (UI, defaultCardOptions, makeCard, windowShow)

import CachedSettings (getCachedOption, setCachedOption)
import Location

serverUrl :: String
serverUrl = "https://uvalert.koterpillar.com"

infoText :: String
infoText = foldl joinPara "" lines where
    lines = [ "UV index is a measure of the strength of sun's ultraviolet radiation."
            , "UV index is 3 or above requires using protective clothing, wearing a"
            , "wide-brimmed hat, UV-blocking sunglasses and SPF 30+ sunscreen."
            , ""
            , "Once you select your location, UV Alert will provide pins on the timeline"
            , "each day to tell you when the UV level is 3 or above, and therefore you"
            , "should protect yourself from the UV radiation."
            , ""
            , "This program is free software: you can redistribute it and/or modify"
            , "it under the terms of the GNU General Public License as published by"
            , "the Free Software Foundation, either version 3 of the License, or"
            , "(at your option) any later version."
            , ""
            , "This program is distributed in the hope that it will be useful,"
            , "but WITHOUT ANY WARRANTY; without even the implied warranty of"
            , "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
            , "GNU General Public License for more details."
            , ""
            , "You should have received a copy of the GNU General Public License"
            , "along with this program.  If not, see <http://www.gnu.org/licenses/>."
            , ""
            , "Australian UV observations courtesy of ARPANSA."
            , ""
            , "USA UV observations courtesy of EPA."
            , ""
            ]
    joinPara :: String -> String -> String
    joinPara l1 "" = l1 ++ "\n\n"
    joinPara l1 l2 = l1 ++ " " ++ l2

locationMaxAge :: Milliseconds
locationMaxAge = Milliseconds $ toNumber $ 1000 * 60 * 60 * 24

getLocationList :: forall e. Aff (now :: Now, ajax :: AJAX, settings :: SETTINGS | e) (Array Location)
getLocationList = do
    cached <- liftEff $ getCachedOption locationMaxAge "locations"
    case cached of
         Just cached' -> return cached'
         Nothing -> do
             resp <- get $ serverUrl ++ "/locations"
             let locations = read resp.response
             case locations of
                  Left err -> throwError $ error $ show err
                  Right locations' -> do
                      liftEff $ setCachedOption "locations" locations'
                      return locations'

eitherToMaybe :: forall a b. Either b a -> Maybe a
eitherToMaybe (Right v) = Just v
eitherToMaybe _ = Nothing

getLocation :: forall e. Eff (now :: Now, ajax :: AJAX, settings :: SETTINGS | e) (Maybe Location)
-- TODO: handle old string value
getLocation = liftM1 eitherToMaybe $ getOption "location"

locTopic :: Location -> String
locTopic loc = "v2-" ++ locState loc ++
                    "-" ++ locRegion loc ++
                    "-" ++ locCity loc

setLocation :: forall e. Location -> Aff (settings :: SETTINGS, timeline :: TIMELINE | e) Unit
setLocation loc = do
    liftEff $ setOption "location" loc
    setSubscriptions [locTopic loc]

main :: forall e. Eff (ui :: UI | e) Unit
main = do
    mainCard <- makeCard $ defaultCardOptions { title = "UV Alert"
                                              }
    windowShow mainCard
    return unit
