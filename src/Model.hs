module Model (ConsulKV) where

import Data.ByteString.Char8 (ByteString)

type ConsulKV = (ByteString, ByteString)
