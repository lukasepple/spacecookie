{-# LANGUAGE OverloadedStrings #-}
module Spacecookie.Gophermap where

import           Prelude                          hiding (take, takeWhile)

import           Spacecookie.ConfigParsing
import           Spacecookie.Monad
import           Spacecookie.Types

import           Control.Applicative              ((<$>), many)
import           Control.Monad.IO.Class           (liftIO)
import           Control.Monad.Reader             (ask)
import           Data.Attoparsec.ByteString.Char8
import           Data.ByteString.Char8            (ByteString (), pack,
                                                   singleton, unpack)
import           Data.Maybe                       (Maybe (..))
import           Data.Word                        (Word8 ())
import           Network.Socket                   (PortNumber ())

data GophermapEntry = GophermapEntry GopherFileType ByteString (Maybe GopherPath) (Maybe ByteString) (Maybe PortNumber)
  deriving (Show, Eq)

type Gophermap = [GophermapEntry]

parseGophermap :: Parser Gophermap
parseGophermap = many parseGophermapLine

parseGophermapLine :: Parser GophermapEntry
parseGophermapLine = do
  fileTypeChar <- anyChar
  text <- itemValue
  pathString <- optionalValue
  host <- optionalValue
  portString <- option Nothing optionalValue
  "\n"
  return $ GophermapEntry (charToFileType fileTypeChar)
    text
    (gopherRequestToPath <$> pathString)
    host
    (byteStringToPort <$> portString)

byteStringToPort :: ByteString -> PortNumber
byteStringToPort s = fromIntegral $ read $ unpack s

optionalValue :: Parser (Maybe ByteString)
optionalValue = option Nothing $ do
  "\t"
  Just <$> itemValue

itemValue :: Parser ByteString
itemValue = takeTill (inClass "\t\r\n")

test :: IO ()
test = do
  print $ parseOnly parseGophermap "1Pygopherd Home\t/devel/gopher/pygopherd\tgopher.quux.org\t70\n1Foobar home\t/dev/foo\niHello World this is an Info text\n"
  return ()