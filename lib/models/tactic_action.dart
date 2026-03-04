class TacticAction {
  final int step;
  final String itemAbbr;
  final int time;
  final String supply;
  final int number;

  TacticAction({
    required this.step,
    required this.itemAbbr,
    required this.time,
    required this.supply,
    required this.number,
  });

  factory TacticAction.fromJson(Map<String, dynamic> json) {
    return TacticAction(
      step: json['Step'] as int? ?? 0,
      itemAbbr: json['ItemAbbr'] as String? ?? '',
      time: json['Time'] as int? ?? 0,
      supply: json['Supply'] as String? ?? '',
      number: json['Number'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Step': step,
      'ItemAbbr': itemAbbr,
      'Time': time,
      'Supply': supply,
      'Number': number,
    };
  }
}
