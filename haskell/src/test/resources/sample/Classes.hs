-- | This file is auto-generated from the ISDA Common
--   Domain Model, do not edit.
--   @version test
module Org.Isda.Cdm.Classes
  ( module Org.Isda.Cdm.Classes ) where

import Org.Isda.Cdm.Enums
import Org.Isda.Cdm.ZonedDateTime
import Org.Isda.Cdm.MetaClasses
import Org.Isda.Cdm.MetaFields
import Prelude hiding (id)

-- | A sample data
data DataFoo = DataFoo {
    intAttribute :: Int
  , multipleAttribute :: [Foo]
  , stringAttribute :: Text
  }
    deriving (Eq, Ord, Show)

-- | A sample class
data Foo = Foo {
    dataAttribute :: DataFoo
  , intAttribute :: Int
  , multipleAttribute :: [Text]
  , stringAttribute :: Text
  }
    deriving (Eq, Ord, Show)

