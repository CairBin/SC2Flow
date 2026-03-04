class TacticIndexItem {
  final String id;
  final String name;
  final String author;
  final String matchup;
  final String applicableVersion;
  final String tacticType;
  final int tacVersion;
  final String modName;
  final int modVersion;
  final String updateTime;
  final String filePath;

  TacticIndexItem({
    required this.id,
    required this.name,
    required this.author,
    required this.matchup,
    required this.applicableVersion,
    required this.tacticType,
    required this.tacVersion,
    required this.modName,
    required this.modVersion,
    required this.updateTime,
    required this.filePath,
  });

  factory TacticIndexItem.fromJson(Map<String, dynamic> json) {
    return TacticIndexItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      author: json['author'] as String? ?? '',
      matchup: json['matchup'] as String? ?? '',
      applicableVersion: json['applicableVersion'] as String? ?? '',
      tacticType: json['tacticType'] as String? ?? '',
      tacVersion: json['tacVersion'] as int? ?? 0,
      modName: json['modName'] as String? ?? '',
      modVersion: json['modVersion'] as int? ?? 0,
      updateTime: json['updateTime'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'matchup': matchup,
      'applicableVersion': applicableVersion,
      'tacticType': tacticType,
      'tacVersion': tacVersion,
      'modName': modName,
      'modVersion': modVersion,
      'updateTime': updateTime,
      'filePath': filePath,
    };
  }
}
