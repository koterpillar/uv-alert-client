module Pebble.Ajax where
-- Pebble AJAX bindings for PureScript

import Prelude (Unit)

import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)

import Data.Foreign (Foreign)
import Data.Function (Fn2, runFn2)

foreign import data AJAX :: !

foreign import ajaxImpl :: forall a e. Fn2 String (Foreign -> a) (Eff (ajax :: AJAX | e) Unit)

type Ajax e a = Aff (ajax :: AJAX | e) a

ajax :: forall e. String -> Ajax e Foreign
ajax url = makeAff (\error success -> runFn2 ajaxImpl url success)
