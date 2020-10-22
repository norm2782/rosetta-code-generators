package com.regnosys.rosetta.generator.haskell.object

import com.regnosys.rosetta.rosetta.RosettaMetaType

import static com.regnosys.rosetta.generator.haskell.util.HaskellModelGeneratorUtil.*

import static extension com.regnosys.rosetta.generator.haskell.util.HaskellTranslator.toHaskellType
import static extension com.regnosys.rosetta.generator.util.Util.*

class HaskellMetaFieldGenerator {
	
	def generateMetaFields(Iterable<RosettaMetaType> metaTypes, String version) {
		metaFields(metaTypes.filter[name!="key" && name!="id" && name!="reference" && name!="template"], version)
	}
	
	def metaFields(Iterable<RosettaMetaType> types, String version) '''
		«fileComment(version)»
		module Org.Isda.Cdm.MetaFields
		  ( module Org.Isda.Cdm.MetaFields ) where
		
		data MetaFields = MetaFields {
		  «FOR type : types.distinctBy(t|t.name.toFirstLower)»
		      «type.name.toFirstLower» :: Maybe «type.type.name.toHaskellType»,
		  «ENDFOR»
		  globalKey :: Maybe Text,
		  externalKey :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)
		
		data MetaAndTemplateFields = MetaAndTemplateFields {
		  «FOR type : types.distinctBy(t|t.name.toFirstLower)»
		      «type.name.toFirstLower» :: Maybe «type.type.name.toHaskellType»,
		  «ENDFOR»
		  globalKey :: Maybe Text,
		  externalKey :: Maybe Text,
		  templateGlobalReference :: Maybe Text
		  }
		    deriving (Eq, Ord, Show)
	'''
}
