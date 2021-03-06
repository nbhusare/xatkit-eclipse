/*
 * generated by Xtext 2.15.0
 */
package com.xatkit.language.execution.jvmmodel

import com.google.inject.Inject
import com.xatkit.execution.ExecutionModel
import com.xatkit.metamodels.utils.RuntimeModel
import com.xatkit.utils.XatkitImportHelper
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import com.xatkit.execution.State
import com.xatkit.intent.EventDefinition
import org.eclipse.xtext.common.types.JvmVisibility

/**
 * <p>Infers a JVM model from the source model.</p> 
 * 
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class ExecutionJvmModelInferrer extends AbstractModelInferrer {

	/**
	 * convenience API to build and initialize JVM types and their members.
	 */
	@Inject extension JvmTypesBuilder

	public static String INFERRED_CLASS_NAME = "ExecutionModel"

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param element
	 *            the model to create one or more
	 *            {@link JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the lambda you pass as the last argument.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
	def dispatch void infer(ExecutionModel element, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		/*
		 * Create the mock classes for Platform.Action(Params). These mocks are represented as static methods to match 
		 * the previous syntax. Note the the generated methods do not contain any execution logic, and are placeholders 
		 * that will be used by the interpreter to trigger the action computation.
		 */
		XatkitImportHelper.instance.getImportedPlatforms(element).forEach [ platform |
			acceptor.accept(platform.toClass(platform.name)) [
				((platform.extends?.actions ?: #[]) + platform.actions).forEach [ action |
					val returnType = action.returnType ?: typeRef(Object)
					members += action.toMethod(action.name, returnType) [
						/*
						 * If the parameter type / return type is not set we assume it is Object. This allows to support
						 * existing platforms without major refactoring.
						 */
						action.parameters.forEach [ parameter |
							parameters += parameter.toParameter(parameter.key, parameter.type ?: typeRef(Object))
						]
						static = true
						body = '''
							// This is a mock class, it shouldn't be called
							return null;
						'''
					]
				]
			]
		]
		
		XatkitImportHelper.instance.getImportedLibraries(element).forEach [ library |
			library.eventDefinitions.forEach[event |
				acceptor.accept(event.toClass(event.name)) [
					superTypes += typeRef(EventDefinition)
					members += event.toField("base", typeRef(EventDefinition)) [
						visibility = JvmVisibility.PUBLIC
						constant = true
						constantValue = event
						static = true
					]
					
					
				]
			]
		]
		
		
		element.eventProviderDefinitions.forEach[provider |
			provider.eventDefinitions.forEach[event |
				acceptor.accept(event.toClass(event.name)) [
					superTypes += typeRef(EventDefinition)
					members += event.toField("base", typeRef(EventDefinition)) [
						visibility = JvmVisibility.PUBLIC
						constant = true
						constantValue = event
						static = true
					]
				]
			]
		]
		/*
		 * Create the main class corresponding to the current execution model. This class contains methods for each 
		 * state transition, and extends the RuntimeModel that provides additional fields to access context, session, and 
		 * configuration.
		 */
		acceptor.accept(element.toClass(INFERRED_CLASS_NAME)) [
			superTypes += typeRef(RuntimeModel)
			element.states.forEach[state |
				var tCount = 0
				for(t : state.transitions) {
					members += t.toMethod("transition" + state.name + tCount, typeRef(Boolean)) [
						body = t.condition
					]
					tCount++
				}
				members += state.body.toMethod("body" + state.name, typeRef(void)) [
					body = state.body
				]
				members += state.fallback.toMethod("fallback" + state.name, typeRef(void)) [
					body = state.fallback
				]
			]
		]
	}
}
