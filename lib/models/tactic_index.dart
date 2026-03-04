import 'tactic_index_item.dart';

class TacticIndex {
  final Map<String, dynamic>? meta;
  final List<TacticIndexItem> tactics;

  TacticIndex({
    this.meta,
    required this.tactics,
  });

  factory TacticIndex.fromJson(Map<String, dynamic> json) {
    var tacticsJson = json['tactics'] as List? ?? [];
    List<TacticIndexItem> tacticsList = tacticsJson
        .map((tacticJson) => TacticIndexItem.fromJson(tacticJson as Map<String, dynamic>))
        .toList();

    return TacticIndex(
      meta: json['meta'] as Map<String, dynamic>?,
      tactics: tacticsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta,
      'tactics': tactics.map((tactic) => tactic.toJson()).toList(),
    };
  }
}
