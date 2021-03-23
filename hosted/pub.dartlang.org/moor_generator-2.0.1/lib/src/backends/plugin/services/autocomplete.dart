import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/completion/completion_core.dart';
import 'package:moor_generator/src/backends/plugin/services/requests.dart';

class MoorCompletingContributor implements CompletionContributor {
  const MoorCompletingContributor();

  @override
  Future<void> computeSuggestions(
      MoorCompletionRequest request, CompletionCollector collector) {
    if (request.isMoorAndParsed) {
      final autoComplete = request.parsedMoor.parseResult.autoCompleteEngine;
      final results = autoComplete.suggestCompletions(request.offset);

      collector
        ..offset = results.anchor
        ..length = results.lengthBefore;

      for (var suggestion in results.suggestions) {
        collector.addSuggestion(CompletionSuggestion(
          CompletionSuggestionKind.KEYWORD,
          suggestion.relevance,
          suggestion.code,
          0,
          0,
          false,
          false,
        ));
      }
    }
    return Future.value();
  }
}
