import 'dart:convert';
import 'dart:io';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/performance_logger.dart';
import 'package:analyzer/src/dart/micro/resolve_file.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/workspace/bazel.dart';
import 'package:crypto/crypto.dart';

main() async {
  var rootPath = '/Users/scheglov/Source/Dart/sdk.git/sdk';
  var workspace = BazelWorkspace.find(resourceProvider, rootPath);

  var sdkPath = '/Users/scheglov/Applications/dart-sdk';
  var sdk = FolderBasedDartSdk(
    resourceProvider,
    resourceProvider.getFolder(sdkPath),
  );

  var fileResolver = FileResolver(
    PerformanceLog(stdout),
    resourceProvider,
    MemoryByteStore(),
    workspace.createSourceFactory(sdk, null),
    (String path) => _getDigest(path),
    null,
    workspace: workspace,
  );

  var path = '$rootPath/pkg/analyzer/lib/src/dart/micro/cider_analyze.dart';
  var result = fileResolver.resolve(
    path: path,
  );
  print(result.unit);

  await Future.delayed(Duration(hours: 42), () => 0);
}

final resourceProvider = PhysicalResourceProvider.INSTANCE;

String _getDigest(String path) {
  try {
    var content = resourceProvider.getFile(path).readAsStringSync();
    var contentBytes = utf8.encode(content);
    return md5.convert(contentBytes).toString();
  } catch (_) {
    return '';
  }
}
