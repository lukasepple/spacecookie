{-# LANGUAGE OverloadedStrings #-}
module Config
  ( Config (..)
  ) where

import Control.Applicative ((<$>), (<*>))
import Control.Monad (mzero)
import Data.Aeson
import Data.Aeson.Types
import Data.ByteString (ByteString ())
import qualified Data.ByteString as B
import Network.Gopher.Util

data Config = Config { serverName    :: ByteString
                     , serverPort    :: Integer
                     , runUserName   :: String
                     , rootDirectory :: FilePath
                     }

instance FromJSON Config where
  parseJSON (Object v) = Config <$>
    v .: "hostname" <*>
    v .: "port" <*>
    v .: "user" <*>
    v .: "root"
  parseJSON _ = mzero

instance ToJSON Config where
  toJSON (Config host port user root) = object
    [ "hostname" .= host
    , "port" .= port
    , "user" .= user
    , "root" .= root
    ]

-- auxiliary instances for types that have no default instance
instance FromJSON ByteString where
  parseJSON (String s) = uEncode <$> (parseJSON (String s))
  parseJSON _ = mzero

instance ToJSON ByteString where
  toJSON = toJSON . uDecode
