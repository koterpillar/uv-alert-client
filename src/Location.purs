module Location where

import Prelude

import Data.Foreign.Class (class IsForeign, readProp)

data Location = Location String String String

locState :: Location -> String
locState (Location state _ _) = state

locRegion :: Location -> String
locRegion (Location _ region _) = region

locCity :: Location -> String
locCity (Location _ _ city) = city

locTitle :: Location -> String
locTitle loc = locCity loc ++ ", " ++ locRegion loc

instance isForeignLocation :: IsForeign Location where
    read value = Location <$> readProp "state" value
                          <*> readProp "region" value
                          <*> readProp "state" value
