/*
 * generated by Xtext 2.12.0
 */
package com.xatkit.language.common.formatting2

import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import com.xatkit.language.common.services.CommonGrammarAccess
import com.xatkit.common.ImportDeclaration
import org.eclipse.xtext.formatting2.IFormattableDocument

class CommonFormatter extends AbstractFormatter2 {
	
	@Inject extension CommonGrammarAccess

	def dispatch void format(ImportDeclaration i, extension IFormattableDocument document) {
		
	}

}
