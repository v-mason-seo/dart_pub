import 'dart:async';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/testing/ast_test_factory.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';
import 'package:analyzer/src/summary2/linked_unit_context.dart';
import 'package:analyzer/src/summary2/reference.dart';
import 'package:analyzer/src/util/file_paths.dart' as file_paths;
import 'package:analyzer/src/workspace/workspace.dart';

main() async {
  ResourceProvider resourceProvider = PhysicalResourceProvider.INSTANCE;
  // var analyzer = '/Users/scheglov/Source/Dart/sdk.git/sdk/pkg/analyzer';
  // var analyzer = '/Users/scheglov/Source/Dart/sdk.git/sdk/pkg/analysis_server';
  // var analyzer = '/Users/scheglov/Source/flutter/examples/image_list';
  var analyzer = '/Users/scheglov/Source/flutter/packages/flutter';
  var collection = AnalysisContextCollectionImpl(
    includedPaths: [analyzer],
    resourceProvider: resourceProvider,
    sdkPath: '/Users/scheglov/Applications/dart-sdk-linked',
  );

  var analysisContext = collection.contextFor(analyzer);

  var fileSystemState = _FileSystemState(
    resourceProvider,
    analysisContext.contextRoot.workspace,
    analysisContext.driver.sourceFactory,
  );
  myFileSystemState = fileSystemState;

  // var tracker = DeclarationsTracker(MemoryByteStore(), resourceProvider);
  // tracker.changes.listen((event) {
  //   // print(event);
  // });
  //  tracker.addContext(analysisContext);
  //
  // while (tracker.hasWork) {
  //   tracker.doWork();
  // }

  var pathList = analysisContext.contextRoot.analyzedFiles().toList();
  pathList.sort();
  for (var path in pathList) {
    if (file_paths.isDart(resourceProvider.pathContext, path)) {
      fileSystemState.fileByPath('', path);
    }
  }

  print('Files: ${fileSystemState.pathToFile.length}');

  await Future.delayed(const Duration(days: 1), () => 0);
  // Timer.periodic(const Duration(seconds: 1), (timer) {
  //   var entries = fileSystemState.pathToFile.entries;
  //   print(entries.first.value.unit.toString().length);
  // });
}

late _FileSystemState myFileSystemState;

class _CompilationUnitElementMock implements CompilationUnitElementImpl {
  @override
  // TODO: implement linkedContext
  LinkedUnitContext? get linkedContext => _LinkedUnitContextMock();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _File {
  final String path;
  final Uri uri;
  late String content;
  late CompilationUnit unit;

  _File(this.path, this.uri);

  @override
  String toString() {
    return '($path, $uri)';
  }
}

class _FileSystemState {
  final ResourceProvider resourceProvider;
  final Workspace workspace;
  final SourceFactory sourceFactory;
  final Map<String, _File> pathToFile = {};
  final Map<Uri, _File> uriToFile = {};

  _FileSystemState(this.resourceProvider, this.workspace, this.sourceFactory);

  _File fileByPath(String dd, String path) {
    var result = pathToFile[path];
    if (result == null) {
      var resource = resourceProvider.getFile(path);
      var fileSource = resource.createSource();
      var uri = sourceFactory.restoreUri(fileSource)!;
      print('$dd $uri -> $path');
      result = _File(path, uri);
      pathToFile[path] = result;
      uriToFile[uri] = result;
      _crawl('$dd  ', result);
    }
    return result;
  }

  void fileByUri(String dd, Uri uri) {
    var result = uriToFile[uri];

    if (result == null) {
      var source = sourceFactory.forUri2(uri);
      if (source != null) {
        var path = source.fullName;
        print('$dd $uri -> $path');
        result = _File(path, uri);
        pathToFile[path] = result;
        uriToFile[uri] = result;
        _crawl('$dd  ', result);
      }
    }
  }

  void _crawl(String dd, _File file) {
    var resource = resourceProvider.getFile(file.path);

    String content;
    try {
      content = resource.readAsStringSync();
    } on FileSystemException {
      return;
    }

    file.content = content;

    var parseResult = parseString(content: content, throwIfDiagnostics: false);
    file.unit = parseResult.unit;
    // file.unit.accept(_RemoveBodiesVisitor());

    for (var directive in file.unit.directives) {
      if (directive is ImportDirective) {
        var uri =
            resolveRelativeUri(file.uri, Uri.parse(directive.uri.stringValue!));
        fileByUri(dd, uri);
      }
      if (directive is ExportDirective) {
        var uri =
            resolveRelativeUri(file.uri, Uri.parse(directive.uri.stringValue!));
        fileByUri(dd, uri);
      }
      if (directive is PartDirective) {
        var uri =
            resolveRelativeUri(file.uri, Uri.parse(directive.uri.stringValue!));
        fileByUri(dd, uri);
      }
    }
  }
}

class _LinkedUnitContextMock implements LinkedUnitContext {
  @override
  bool get isLinking => true;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
class _RemoveBodiesVisitor extends RecursiveAstVisitor<void> {
  final Reference rootReference = Reference.root();
  final CompilationUnitElementImpl _unitElement = _CompilationUnitElementMock();
  ClassElementImpl? enclosingClass;
  MixinElementImpl? _enclosingMixin;
  ExtensionElementImpl? _enclosingExtension;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    enclosingClass = ClassElementImpl.forLinkedNode(
      _unitElement,
      rootReference.getChild('@class').getChild(node.name.name),
      node,
    );
    super.visitClassDeclaration(node);
    enclosingClass = null;
  }

  @override
  void visitConstructorDeclaration(covariant ConstructorDeclarationImpl node) {
    // ignore: deprecated_member_use_from_same_package
    node.body = AstTestFactory.emptyFunctionBody();
  }

  @override
  void visitExtensionDeclaration(covariant ExtensionDeclarationImpl node) {
    var nameNode = node.name;
    if (nameNode != null) {
      _enclosingExtension = ExtensionElementImpl.forLinkedNode(
        _unitElement,
        rootReference.getChild('@extension').getChild(nameNode.name),
        node,
      );
    }
    super.visitExtensionDeclaration(node);
    _enclosingExtension = null;
  }

  @override
  void visitFunctionDeclaration(covariant FunctionDeclarationImpl node) {
    // ignore: deprecated_member_use_from_same_package
    node.functionExpression.body = AstTestFactory.emptyFunctionBody();
  }

  @override
  void visitMethodDeclaration(covariant MethodDeclarationImpl node) {
    var enclosingElement =
        enclosingClass ?? _enclosingMixin ?? _enclosingExtension;
    if (enclosingElement != null) {
      MethodElementImpl.forLinkedNode(
        enclosingElement,
        rootReference.getChild('@method').getChild(node.name.name),
        node,
      );
    }
    node.body = AstTestFactory.emptyFunctionBody();
  }

  @override
  void visitMixinDeclaration(covariant MixinDeclarationImpl node) {
    _enclosingMixin = MixinElementImpl.forLinkedNode(
      _unitElement,
      rootReference.getChild('@mixin').getChild(node.name.name),
      node,
    );
    super.visitMixinDeclaration(node);
    _enclosingMixin = null;
  }
}
