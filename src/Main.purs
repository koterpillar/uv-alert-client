module Main where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)

import Data.Date (Date, Now, fromEpochMilliseconds, now, toEpochMilliseconds)
import Data.Time (Milliseconds(..))

import Data.Either (Either(..))

import Data.Foldable (foldl)

import Data.Foreign (ForeignError(..))
import Data.Foreign.Class (class IsForeign, readProp)

import Data.Int (toNumber)

import Data.Maybe (Maybe(..))

import Network.HTTP.Affjax (AJAX)

import Pebble.Settings (SETTINGS, getOption)

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

data Location = Location String String String

instance isForeignLocation :: IsForeign Location where
    read value = Location <$> readProp "state" value
                          <*> readProp "region" value
                          <*> readProp "state" value

data Cached a = Cached Date a

instance isForeignCached :: IsForeign a => IsForeign (Cached a) where
    read value = do
        timestamp <- liftM1 (fromEpochMilliseconds <<< Milliseconds <<< toNumber) $ readProp "timestamp" value
        case timestamp of
             Just timestamp' -> do
                                    dataVal <- readProp "data" value
                                    return $ Cached timestamp' dataVal
             Nothing -> Left (TypeMismatch "int" "undefined")

locationMaxAge :: Milliseconds
locationMaxAge = Milliseconds $ toNumber $ 1000 * 60 * 60 * 24

isRecent :: forall e. Milliseconds -> Date -> Eff (now :: Now | e) Boolean
isRecent maxAge timestamp = do
    currentDate <- now
    let age = toEpochMilliseconds currentDate - toEpochMilliseconds timestamp
    return $ age <= maxAge

getCachedOption :: forall a e. IsForeign a => Milliseconds -> String -> Eff (now :: Now, settings :: SETTINGS | e) (Maybe a)
getCachedOption maxAge name = do
    cached <- getOption name
    case cached of
         Right (Cached timestamp val) -> do
             recent <- isRecent maxAge timestamp
             return $ if recent then Just val else Nothing
         Left _ -> return Nothing

getLocationList :: forall e. Aff (now :: Now, ajax :: AJAX, settings :: SETTINGS | e) (Array Location)
getLocationList = do
    cached <- liftEff $ getCachedOption locationMaxAge "locations"
    case cached of
         Just cached' -> return cached'
         Nothing -> do
             -- TODO
             return []

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
    log infoText
