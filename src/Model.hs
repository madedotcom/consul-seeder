{-# LANGUAGE DeriveGeneric #-}

module Model (ConsulKV, key, value) where

import GHC.Generics
import Data.Yaml

data ConsulKV = ConsulKV
    { key :: String
    , value :: String
    } deriving (Generic,Show)

instance FromJSON ConsulKV