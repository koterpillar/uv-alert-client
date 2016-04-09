module Pebble.UI ( class Window
                 , toWindowPointer -- can this not be exported?
                 , ActionButton(..)
                 , Card
                 , CardOptions(..)
                 , CardBodyStyle(..)
                 , Icon
                 , defaultCardOptions
                 , makeCard
                 , windowShow
                 , UI
                 )
where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)

import Data.Foreign (Foreign)
import Data.Map as M
import Data.Maybe (Maybe(..))


foreign import data UI :: !

type UIEff e = Eff (ui :: UI | e)
type UIAff e = Aff (ui :: UI | e)

data ActionButton = Up | Select | Down

data Card = Card Foreign

data CardBodyStyle = Small | Large | Mono

type Icon = String

type CardOptions = { title :: String
                   , subtitle :: String
                   , body :: String
                   , icon :: Maybe Icon
                   , subicon :: Maybe Icon
                   , banner :: Maybe Icon
                   , scrollable :: Boolean
                   , style :: CardBodyStyle
                   , actions :: M.Map ActionButton Icon
                   }

defaultCardOptions :: CardOptions
defaultCardOptions = { title: ""
                     , subtitle: ""
                     , body: ""
                     , icon: Nothing
                     , subicon: Nothing
                     , banner: Nothing
                     , scrollable: false
                     , style: Small
                     , actions: M.empty
                     }

foreign import _makeCard :: forall e. CardOptions -> UIEff e Foreign

makeCard :: forall e. CardOptions -> UIEff e Card
makeCard = _makeCard >>> liftM1 Card

class Window a where
    toWindowPointer :: a -> Foreign

instance cardWindow :: Window Card where
    toWindowPointer (Card ptr) = ptr

foreign import _windowShow :: forall e. Foreign -> UIEff e Unit

windowShow :: forall a e. Window a => a -> UIEff e Unit
windowShow w = _windowShow (toWindowPointer w)
