package com.regnosys.rosetta.generator.haskell

import com.google.inject.Inject
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.junit.jupiter.api.Assertions.*
import com.regnosys.rosetta.tests.util.ModelHelper
import com.regnosys.rosetta.rosetta.RosettaModel

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class HaskellModelObjectGeneratorTest {

	@Inject extension ModelHelper
	@Inject HaskellCodeGenerator generator;
	

	@Test
	def void shouldGenerateClassWithImports() {
		val haskell = '''
			type Foo:
			    stringAttr string (0..1)
		'''.generateHaskell
		
		val classes = haskell.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''import Org.Isda.Cdm.Enums'''))
		assertTrue(classes.contains('''import Org.Isda.Cdm.ZonedDateTime'''))
		assertTrue(classes.contains('''import Org.Isda.Cdm.MetaClasses'''))
		assertTrue(classes.contains('''import Prelude hiding (id)'''))
	}

	@Test
	def void shouldGenerateClassWithBasicTypes() {
		val classes = '''
			type Foo:
			    stringAttr string (1..1)
			    intAttr int (1..1)
			    numberAttr number (1..1)
			    booleanAttr boolean (1..1)
			    dateAttr date (1..1)
			    timeAttr time (1..1)
				zonedDateTimeAttr zonedDateTime (1..1)
		'''.generateHaskell.get("Org/Isda/Cdm/Classes.hs").toString

		assertTrue(classes.contains('''
		data Foo = Foo {
		  booleanAttr :: Bool,
		  dateAttr :: Date,
		  intAttr :: Int,
		  numberAttr :: Decimal,
		  stringAttr :: Text,
		  timeAttr :: Text,
		  zonedDateTimeAttr :: ZonedDateTime
		  }
		    deriving (Eq, Ord, Show)'''))
	}

	@Test
	def void shouldGenerateClassWithOptionalBasicType() {
		val classes = '''
			type Foo:
			    stringAttr string (0..1)
		'''.generateHaskell.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Foo = Foo {
		  stringAttr :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)'''))
	}

	@Test
	def void shouldGenerateClassWithComments() {
		val classes = '''
			type Foo: <"This is the class comment which should wrap if the line is long enough.">
			    stringAttr string (0..1) <"This is the attribute comment which should also wrap if long enough">
		'''.generateHaskell.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		-- | This is the class comment which should wrap if the
		--   line is long enough.
		data Foo = Foo {
		  stringAttr :: Maybe Text
		    -- ^ This is the attribute comment which should also wrap
		    --   if long enough
		  }
		    deriving (Eq, Ord, Show)'''))
	}

	@Test
	def void shouldGenerateClassWithBasicTypeList() {
		val classes = '''
			type Foo:
			    stringAttrs string (0..*)
		'''.generateHaskell.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Foo = Foo {
		  stringAttrs :: [Text]
		  }
		    deriving (Eq, Ord, Show)'''))
	}
	
	@Test
	def void shouldGenerateClassWithBasicTypeAndMetaFieldScheme() {
		val code = '''
			metaType scheme string
			
			type Foo:
			    stringAttr string (1..1)
			    [metadata scheme]
		'''.generateHaskell
		
		val classes = code.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Foo = Foo {
		  stringAttr :: (FieldWithMeta Text)
		  }
		    deriving (Eq, Ord, Show)'''))

		val metaFields = code.get("Org/Isda/Cdm/MetaFields.hs").toString
		
		assertTrue(metaFields.contains('''
		-- | This file is auto-generated from the ISDA Common
		--   Domain Model, do not edit.
		--   @version test
		module Org.Isda.Cdm.MetaFields
		  ( module Org.Isda.Cdm.MetaFields ) where
		
		data MetaFields = MetaFields {
		  scheme :: Maybe Text,
		  globalKey :: Maybe Text,
		  externalKey :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)'''))
	}
	
	@Test
	def void shouldGenerateClassWithOptionalRosettaType() {
		val classes = '''
			type Foo:
			    barAttr Bar (0..1)
			
			type Bar:
			    stringAttr string (1..1)
		'''.generateHaskell.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Foo = Foo {
		  barAttr :: Maybe Bar
		  }
		    deriving (Eq, Ord, Show)'''))
	}
	
	@Test
	def void shouldGenerateClassWithRosettaTypeAndMetaReference() {
		val code = '''
			metaType reference string
			
			type Foo:
			    barReference Bar (0..1)
			    [metadata reference]
			
			type Bar:
			    [metadata key]
			    stringAttr string (1..1)
		'''.generateHaskell
		
		val classes = code.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Bar = Bar {
		  meta :: Maybe MetaFields,
		  stringAttr :: Text
		  }
		    deriving (Eq, Ord, Show)'''))

		assertTrue(classes.contains('''
		data Foo = Foo {
		  barReference :: Maybe (ReferenceWithMeta Bar)
		  }
		    deriving (Eq, Ord, Show)'''))

		val metaFields = code.get("Org/Isda/Cdm/MetaFields.hs").toString
		
		assertTrue(metaFields.contains('''
		-- | This file is auto-generated from the ISDA Common
		--   Domain Model, do not edit.
		--   @version test
		module Org.Isda.Cdm.MetaFields
		  ( module Org.Isda.Cdm.MetaFields ) where
		
		data MetaFields = MetaFields {
		  globalKey :: Maybe Text,
		  externalKey :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)'''))
	}
	
	@Test
	def void shouldGenerateClassWithRosettaTypeAndMetaBasicReference() {
		val code = '''
			metaType reference string
			
			type Foo:
			    stringReference string (0..1)
			    [metadata reference]
		'''.generateHaskell
		
		val classes = code.get("Org/Isda/Cdm/Classes.hs").toString
		
		assertTrue(classes.contains('''
		data Foo = Foo {
		  stringReference :: Maybe (BasicReferenceWithMeta Text)
		  }
		    deriving (Eq, Ord, Show)'''))

		val metaFields = code.get("Org/Isda/Cdm/MetaFields.hs").toString
		
		// println(metaFields)
		
		assertTrue(metaFields.contains('''
		-- | This file is auto-generated from the ISDA Common
		--   Domain Model, do not edit.
		--   @version test
		module Org.Isda.Cdm.MetaFields
		  ( module Org.Isda.Cdm.MetaFields ) where
		
		data MetaFields = MetaFields {
		  globalKey :: Maybe Text,
		  externalKey :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)'''))
	}
	
	
	
	def generateHaskell(CharSequence model) {
		val eResource = model.parseRosettaWithNoErrors.eResource
		
		generator.afterGenerate(eResource.contents.filter(RosettaModel).toList)
	}
}
