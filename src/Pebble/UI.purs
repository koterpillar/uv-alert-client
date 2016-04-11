module Pebble.UI ( class Window
                 , toWindowPointer -- can this not be exported?
                 , ActionButton(..)
                 , Card
                 , CardOptions(..)
                 , CardBodyStyle(..)
                 , Icon(..)
                 , defaultCardOptions
                 , makeCard
                 , windowShow
                 , UI
                 )
where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)

import Data.Foreign (Foreign, toForeign)
import Data.Generic (class Generic, gEq, gCompare)
import Data.Map as M
import Data.Maybe (Maybe(..), fromMaybe)


foreign import data UI :: !

type UIEff e = Eff (ui :: UI | e)
type UIAff e = Aff (ui :: UI | e)

data ActionButton = Up | Select | Down

derive instance genericActionButton :: Generic ActionButton

instance genericEq :: Eq ActionButton where
    eq = gEq

instance genericOrd :: Ord ActionButton where
    compare = gCompare

type ActionMap a = { up :: Foreign
                   , select :: Foreign
                   , down :: Foreign
                   }

foreign import _null :: Foreign

toForeignMaybe :: forall a. Maybe a -> Foreign
toForeignMaybe = liftM1 toForeign >>> fromMaybe _null

toActionMap :: forall a. M.Map ActionButton a -> ActionMap a
toActionMap m = { up: lookup Up m
                , select: lookup Select m
                , down: lookup Down m
                }
    where lookup :: ActionButton -> M.Map ActionButton a -> Foreign
          lookup button = M.lookup button >>> toForeignMaybe

data Card = Card Foreign

data CardBodyStyle = Small | Large | Mono

instance showCardBodyStyle :: Show CardBodyStyle where
    show Small = "small"
    show Large = "large"
    show Mono = "mono"

newtype Icon = Icon String

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

foreign import _makeCard :: forall e. Foreign -> UIEff e Foreign

makeCard :: forall e. CardOptions -> UIEff e Card
makeCard options = do
    let options' = { title: options.title
                   , subtitle: options.subtitle
                   , body: options.body
                   , icon: toForeignMaybe options.icon
                   , subicon: toForeignMaybe options.subicon
                   , banner: toForeignMaybe options.banner
                   , scrollable: options.scrollable
                   , style: show options.style
                   , action: toActionMap options.actions
                   }
    card <- _makeCard (toForeign options')
    return $ Card card

class Window a where
    toWindowPointer :: a -> Foreign

instance cardWindow :: Window Card where
    toWindowPointer (Card ptr) = ptr

foreign import _windowShow :: forall e. Foreign -> UIEff e Unit

windowShow :: forall a e. Window a => a -> UIEff e Unit
windowShow w = _windowShow (toWindowPointer w)
