package com.xatkit.language.execution;

import static java.text.MessageFormat.format;
import static java.util.Objects.nonNull;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.linking.impl.DefaultLinkingService;
import org.eclipse.xtext.linking.impl.IllegalNodeException;
import org.eclipse.xtext.nodemodel.INode;

import com.xatkit.execution.ExecutionModel;
import com.xatkit.execution.ExecutionPackage;
import com.xatkit.platform.EventProviderDefinition;
import com.xatkit.platform.PlatformDefinition;
import com.xatkit.utils.XatkitImportHelper;

public class ExecutionLinkingService extends DefaultLinkingService {

	private static final Logger log = Logger.getLogger(ExecutionLinkingService.class);
	
	public ExecutionLinkingService() {
		super();
		log.debug(format("{0} started", this.getClass().getSimpleName()));
	}

	@Override
	public List<EObject> getLinkedObjects(EObject context, EReference ref, INode node) throws IllegalNodeException {
		log.debug(format("{0} linking context: {1}", this.getClass().getSimpleName(), context));
		log.debug(format("{0} linking reference: {1}", this.getClass().getSimpleName(), ref));
		if (context instanceof ExecutionModel) {
			return getLinkedObjectsForExecutionModel((ExecutionModel) context, ref, node);
		} else {
			return super.getLinkedObjects(context, ref, node);
		}
	}

	private List<EObject> getLinkedObjectsForExecutionModel(ExecutionModel context, EReference ref, INode node) {
		if (ref.equals(ExecutionPackage.eINSTANCE.getExecutionModel_EventProviderDefinitions())) {
			QualifiedName qualifiedName = getQualifiedName(node.getText());
			if (nonNull(qualifiedName)) {
				String platformName = qualifiedName.getQualifier();
				String eventProviderName = qualifiedName.getLocalName();
				PlatformDefinition platformDefinition = XatkitImportHelper.getInstance()
						.getImportedPlatform((ExecutionModel) context, platformName);
				if (nonNull(platformDefinition)) {
					EventProviderDefinition eventProviderDefinition = platformDefinition
							.getEventProviderDefinition(eventProviderName);
					if (nonNull(eventProviderDefinition)) {
						return Arrays.asList(eventProviderDefinition);
					}
				}
			}
			return Collections.emptyList();
		} else {
			return super.getLinkedObjects(context, ref, node);
		}
	}

	private QualifiedName getQualifiedName(String from) {
		String trimmed = from.trim();
		String[] splitted = trimmed.split("\\.");
		if (splitted.length != 2) {
			/*
			 * We don't handle qualified name that contain multiple or no qualifier.
			 */
			log.warn(format("Cannot compute a qualified name from the provided String {0}", from));
			return null;
		} else {
			return new QualifiedName(splitted[0], splitted[1]);
		}
	}
}
