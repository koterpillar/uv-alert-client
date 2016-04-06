module CachedSettings ( getCachedOption
                      , setCachedOption
                      )
where

import Prelude

import Control.Monad.Eff (Eff)

import Data.Date (Date, Now, fromEpochMilliseconds, now, toEpochMilliseconds)
import Data.Time (Milliseconds(..))

import Data.Foreign (ForeignError(..))
import Data.Foreign.Class (class IsForeign, readProp)

import Data.Either (Either(..))

import Data.Int (toNumber)

import Data.Maybe (Maybe(..))

import Pebble.Settings (SETTINGS, getOption, setOption)

data Cached a = Cached Date a

instance isForeignCached :: IsForeign a => IsForeign (Cached a) where
    read value = do
        timestamp <- liftM1 (fromEpochMilliseconds <<< Milliseconds <<< toNumber) $ readProp "timestamp" value
        case timestamp of
             Just timestamp' -> do
                                    dataVal <- readProp "data" value
                                    return $ Cached timestamp' dataVal
             Nothing -> Left (TypeMismatch "int" "undefined")

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

setCachedOption :: forall a e. String -> a -> Eff (now :: Now, settings :: SETTINGS | e) Unit
setCachedOption name value = do
    currentDate <- now
    setOption name (Cached currentDate value)
