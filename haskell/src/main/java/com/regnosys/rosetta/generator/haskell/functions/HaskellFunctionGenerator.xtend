package com.regnosys.rosetta.generator.haskell.functions

import com.regnosys.rosetta.generator.haskell.object.HaskellModelObjectBoilerPlate
import com.regnosys.rosetta.rosetta.RosettaCardinality
import com.regnosys.rosetta.rosetta.RosettaNamed
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.FunctionDispatch
import java.util.HashMap
import java.util.List
import java.util.Map
import javax.inject.Inject

import static com.regnosys.rosetta.generator.haskell.util.HaskellModelGeneratorUtil.*

import static extension com.regnosys.rosetta.generator.haskell.util.HaskellTranslator.toHaskellType

class HaskellFunctionGenerator {
	@Inject extension HaskellModelObjectBoilerPlate
	
	static final String FILENAME = 'Org/Isda/Cdm/Functions.hs'
		
	def Map<String, ? extends CharSequence> generate(Iterable<RosettaNamed> rosettaFunctions, String version) {
		val result = new HashMap
		val functions = rosettaFunctions.sortBy[name].generateFunctions(version).replaceTabsWithSpaces
		result.put(FILENAME,functions)
		return result;
	}
	
	private def generateFunctions(List<RosettaNamed> functions, String version)  '''
		«fileComment(version)»
		module Org.Isda.Cdm.Functions
		  ( module Org.Isda.Cdm.Functions ) where
		
		import Org.Isda.Cdm.Classes
		import Org.Isda.Cdm.Enums
		import Org.Isda.Cdm.ZonedDateTime
		import Org.Isda.Cdm.MetaClasses
		import Org.Isda.Cdm.MetaFields
		import Prelude hiding (id)
		
		«FOR f : functions»
			«writeFunction(f)»
			
		«ENDFOR»
	'''
	
	private def dispatch writeFunction(RosettaNamed f)''''''
	
	private def dispatch writeFunction(Function f)
	'''
		«classComment("Function argument object definition for "+f.name)»
		data «f.name.toFirstUpper»Spec = «f.name.toFirstUpper»Spec {
		  «FOR input : f.inputs SEPARATOR ',' »
		  «input.name» :: «input.toType»
		  «ENDFOR»
		  }
		    deriving (Eq, Ord, Show)
		
		«classComment("Function definition for "+f.name)»
		«f.name.toFirstLower»Func : («f.name»Spec -> «f.output.toType») -> «f.name»Spec -> «f.output.toType»
		«f.name.toFirstLower»Func impl spec = impl spec
	'''
	
	private def dispatch writeFunction(FunctionDispatch f)
	''''''
	
	private def toType(Attribute att) {
		if (att.card!==null && att.card.sup>1)
			'''[«att.toRawType»]'''
		else
			att.toRawType.prefixSingleOptional(att.card)
	}
	
	private def toRawType(Attribute input) {
		input.type.name.toHaskellType	
	}
	
	private def prefixSingleOptional(CharSequence type, RosettaCardinality card) {
		if (card!==null && card.inf<1)
			'''Optional «type»'''
		else
			type
	}
}
