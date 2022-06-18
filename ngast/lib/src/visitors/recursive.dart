import 'package:meta/meta.dart';

import '../ast.dart';
import '../visitor.dart';

/// An [TemplateAstVisitor] that recursively visits all children of an AST node,
/// in addition to itself.
///
/// Note that methods may modify values.
class RecursiveTemplateAstVisitor<C>
    implements TemplateAstVisitor<TemplateAst, C?> {
  @literal
  const RecursiveTemplateAstVisitor();

  /// Visits a collection of [TemplateAst] nodes, returning all of those that
  /// are not null.
  List<T>? visitAll<T extends TemplateAst>(Iterable<T>? astNodes,
      [C? context]) {
    if (astNodes == null) return null;

    final results = <T>[];
    for (final astNode in astNodes) {
      var value = visit(astNode, context);
      if (value != null) {
        results.add(value);
      }
    }
    return results;
  }

  /// Visits a single [TemplateAst] node, capturing the type.
  T? visit<T extends TemplateAst>(T? astNode, [C? context]) {
    return astNode?.accept(this, context) as T?;
  }

  @override
  TemplateAst visitAnnotation(AnnotationAst astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  TemplateAst visitAttribute(AttributeAst astNode, [C? context]) {
    return AttributeAst.from(
      astNode,
      astNode.name,
      astNode.value,
      visitAll(astNode.mustaches, context),
    );
  }

  @override
  TemplateAst visitBanana(BananaAst astNode, [C? context]) {
    return astNode;
  }

  @override
  TemplateAst visitCloseElement(CloseElementAst astNode, [C? context]) {
    return astNode;
  }

  @override
  TemplateAst visitComment(CommentAst astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  TemplateAst visitContainer(ContainerAst astNode, [C? context]) {
    return ContainerAst.from(
      astNode,
      annotations: visitAll(astNode.annotations, context) ?? [],
      childNodes: visitAll(astNode.childNodes, context) ?? [],
      stars: visitAll(astNode.stars, context) ?? [],
    );
  }

  @override
  TemplateAst visitEmbeddedContent(EmbeddedContentAst astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  TemplateAst visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [C? context]) {
    return EmbeddedTemplateAst.from(
      astNode,
      annotations: visitAll(astNode.annotations, context) ?? [],
      attributes: visitAll(astNode.attributes, context) ?? [],
      childNodes: visitAll(astNode.childNodes, context) ?? [],
      events: visitAll(astNode.events, context) ?? [],
      properties: visitAll(astNode.properties, context) ?? [],
      references: visitAll(astNode.references, context) ?? [],
      letBindings: visitAll(astNode.letBindings, context) ?? [],
    );
  }

  @override
  @mustCallSuper
  TemplateAst? visitElement(ElementAst astNode, [C? context]) {
    return ElementAst.from(
      astNode,
      astNode.name,
      visit(astNode.closeComplement),
      attributes: visitAll(astNode.attributes, context) ?? [],
      childNodes: visitAll(astNode.childNodes, context) ?? [],
      events: visitAll(astNode.events, context) ?? [],
      properties: visitAll(astNode.properties, context) ?? [],
      references: visitAll(astNode.references, context) ?? [],
      bananas: visitAll(astNode.bananas, context) ?? [],
      stars: visitAll(astNode.stars, context) ?? [],
      annotations: visitAll(astNode.annotations, context) ?? [],
    );
  }

  @override
  @mustCallSuper
  TemplateAst visitEvent(EventAst astNode, [C? context]) {
    return EventAst.from(
      astNode,
      astNode.name,
      astNode.value,
      astNode.reductions,
    );
  }

  @override
  @mustCallSuper
  TemplateAst visitInterpolation(InterpolationAst astNode, [C? context]) {
    return InterpolationAst.from(
      astNode,
      astNode.value,
    );
  }

  @override
  TemplateAst visitLetBinding(LetBindingAst astNode, [C? context]) {
    return astNode;
  }

  @override
  @mustCallSuper
  TemplateAst visitProperty(PropertyAst astNode, [C? context]) {
    return PropertyAst.from(
      astNode,
      astNode.name,
      astNode.value,
      astNode.postfix,
      astNode.unit,
    );
  }

  @override
  TemplateAst visitReference(ReferenceAst astNode, [C? context]) {
    return astNode;
  }

  @override
  TemplateAst visitStar(StarAst astNode, [C? context]) {
    return astNode;
  }

  @override
  TemplateAst visitText(TextAst astNode, [C? context]) {
    return astNode;
  }
}
