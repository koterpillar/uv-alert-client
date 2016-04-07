module Pebble.Timeline ( TIMELINE
                       , getSubscriptions
                       , subscribe
                       , unsubscribe
                       , setSubscriptions
                       )
where

import Prelude

import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)

import Data.Function (Fn2, runFn2)

import Data.Traversable (traverse)

import Data.Set as S

foreign import data TIMELINE :: !

foreign import _getSubscriptions :: forall a e. (Array String -> a) -> (Eff (timeline :: TIMELINE | e) Unit)

foreign import _subscribe :: forall a e. Fn2 String (Unit -> a) (Eff (timeline :: TIMELINE | e) Unit)

foreign import _unsubscribe :: forall a e. Fn2 String (Unit -> a) (Eff (timeline :: TIMELINE | e) Unit)

getSubscriptions :: forall e. Aff (timeline :: TIMELINE | e) (Array String)
getSubscriptions = makeAff $ \_ success -> _getSubscriptions success

subscribe :: forall e. String -> Aff (timeline :: TIMELINE | e) Unit
subscribe topic = makeAff $ \_ success -> runFn2 _subscribe topic success

unsubscribe :: forall e. String -> Aff (timeline :: TIMELINE | e) Unit
unsubscribe topic = makeAff $ \_ success -> runFn2 _unsubscribe topic success

setSubscriptions :: forall e. Array String -> Aff (timeline :: TIMELINE | e) Unit
setSubscriptions topics = do
    subscribed <- liftM1 S.fromFoldable getSubscriptions
    let needed = S.fromFoldable topics
    let toAdd = S.difference needed subscribed
    let toRemove = S.difference subscribed needed
    traverse subscribe $ S.toList toAdd
    traverse unsubscribe $ S.toList toRemove
    return unit
