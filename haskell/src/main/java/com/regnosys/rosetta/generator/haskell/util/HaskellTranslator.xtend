package com.regnosys.rosetta.generator.haskell.util

import com.regnosys.rosetta.types.RCalculationType
import com.regnosys.rosetta.types.RQualifiedType

class HaskellTranslator {
				
	static def toHaskellBasicType(String typename) {
		switch typename {
			case 'String':
				'Text'
			case 'string':
				'Text'
			case 'int':
				'Int'
			case 'time':
				'Text'
			case 'date':
				'Date'
			case 'dateTime':
				'Time'
			case 'zonedDateTime':
				'ZonedDateTime'
			case 'number':
				'Decimal'
			case 'boolean':
				'Bool'
			case RQualifiedType.PRODUCT_TYPE.qualifiedType:
				'Text'
			case RQualifiedType.EVENT_TYPE.qualifiedType:
				'Text'
			case RCalculationType.CALCULATION.calculationType:
				'Text'
		}
	}

	static def toHaskellType(String typename) {
		val basicType = toHaskellBasicType(typename);
		if (basicType !== null)
			return basicType
		else
			return typename
	}
}
