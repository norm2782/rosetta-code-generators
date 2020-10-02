package com.regnosys.rosetta.generator.haskell.object

import com.regnosys.rosetta.generator.object.ExpandedAttribute

import static extension com.regnosys.rosetta.generator.haskell.util.HaskellTranslator.toHaskellType

class HaskellModelObjectBoilerPlate {
		
	def toAttributeName(ExpandedAttribute attribute) {
		if (attribute.name == "type")
			'''_type'''
		else
			attribute.name.toFirstLower
	}
	
	def replaceTabsWithSpaces(CharSequence code) {
		code.toString.replace('\t', '  ')
	}
	
	def toType(ExpandedAttribute attribute) {
		if (attribute.isMultiple) 
			'''[«attribute.toRawType»]'''
		else
			attribute.toRawType
				.wrapSingleMetaInBrackets(attribute)
				.prefixSingleOptional(attribute)
	}
	
	private def toRawType(ExpandedAttribute attribute) {
		if (!attribute.hasMetas) 
			attribute.type.name.toHaskellType
		else if (attribute.refIndex>=0) {
			if (attribute.type.isType)
				attribute.type.name.toReferenceWithMetaTypeName
			else 
				attribute.type.name.toBasicReferenceWithMetaTypeName
		}
		else 
			attribute.type.name.toFieldWithMetaTypeName
	}
	
	private def toReferenceWithMetaTypeName(String type) {
		'''ReferenceWithMeta «type.toHaskellType.toFirstUpper»'''
	}
	
	private def toBasicReferenceWithMetaTypeName(String type) {
		'''BasicReferenceWithMeta «type.toHaskellType.toFirstUpper»'''
	}
	
	private def toFieldWithMetaTypeName(String type) {
		'''FieldWithMeta «type.toHaskellType.toFirstUpper»'''
	}
	
	private def prefixSingleOptional(CharSequence type, ExpandedAttribute attribute) {
		if (attribute.isSingleOptional)
			'''Maybe «type»'''
		else
			type
	}
	
	private def wrapSingleMetaInBrackets(CharSequence type, ExpandedAttribute attribute) {
		if (attribute.hasMetas) 
			'''(«type»)'''
		else
			type
	}
}
