import 'tactic_action.dart';

class TacticDetail {
  final String id;
  final String name;
  final String author;
  final String description;
  final String applicableVersion;
  final String tacticType;
  final int tacVersion;
  final String updateTime;
  final String modName;
  final int modVersion;
  final String matchup;
  final List<TacticAction> actions;
  final String actionsListStr;

  TacticDetail({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.applicableVersion,
    required this.tacticType,
    required this.tacVersion,
    required this.updateTime,
    required this.modName,
    required this.modVersion,
    required this.matchup,
    required this.actions,
    required this.actionsListStr,
  });

  factory TacticDetail.fromJson(Map<String, dynamic> json) {
    var actionsJson = json['Actions'] as List? ?? [];
    List<TacticAction> actionsList = actionsJson
        .map((actionJson) => TacticAction.fromJson(actionJson as Map<String, dynamic>))
        .toList();

    return TacticDetail(
      id: json['Id'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      author: json['Author'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      applicableVersion: json['ApplicableVersion'] as String? ?? '',
      tacticType: json['TacticType'] as String? ?? '',
      tacVersion: json['TacVersion'] as int? ?? 0,
      updateTime: json['UpdateTime'] as String? ?? '',
      modName: json['ModName'] as String? ?? '',
      modVersion: json['ModVersion'] as int? ?? 0,
      matchup: json['Matchup'] as String? ?? '',
      actions: actionsList,
      actionsListStr: json['ActionsListStr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Author': author,
      'Description': description,
      'ApplicableVersion': applicableVersion,
      'TacticType': tacticType,
      'TacVersion': tacVersion,
      'UpdateTime': updateTime,
      'ModName': modName,
      'ModVersion': modVersion,
      'Matchup': matchup,
      'Actions': actions.map((action) => action.toJson()).toList(),
      'ActionsListStr': actionsListStr,
    };
  }
}
