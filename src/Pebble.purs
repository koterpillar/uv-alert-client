module Pebble ( initPebble
              , PEBBLE
              ) where

import Prelude (Unit)

import Control.Monad.Eff (Eff)

foreign import data PEBBLE :: !

foreign import initPebble :: forall e. Eff (pebble :: PEBBLE | e) Unit
