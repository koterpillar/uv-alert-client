-- Pebble settings bindings for PureScript
module Pebble.Settings ( getOption
                       , setOption
                       , SETTINGS
                       )
where

import Prelude (($), Unit, bind, return)

import Control.Monad.Eff (Eff)

import Data.Foreign (F, Foreign, toForeign)
import Data.Foreign.Class (class IsForeign, read)

import Data.Function (Fn2, runFn2)

foreign import data SETTINGS :: !

type SettingsEff e = Eff (settings :: SETTINGS | e)

foreign import _getOption :: forall e. String -> SettingsEff e Foreign

foreign import _setOption :: forall e. Fn2 String Foreign (SettingsEff e Unit)

getOption :: forall a e. IsForeign a => String -> SettingsEff e (F a)
getOption name = do
  value <- _getOption name
  return $ read value

setOption :: forall a e. String -> a -> SettingsEff e Unit
setOption name value = runFn2 _setOption name $ toForeign value
