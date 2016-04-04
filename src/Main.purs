module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

import Data.Foldable (foldl)

import Pebble.Ajax

serverUrl :: String
serverUrl = "https://uvalert.koterpillar.com"

locationMaxAge :: Int
locationMaxAge = 60 * 60 * 24  -- seconds

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

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log infoText
