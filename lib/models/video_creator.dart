class VideoCreator {
  final String id;
  final String name;
  final String avatar;
  final String title;
  final String description;
  final String url;
  final String processedAvatar;

  VideoCreator({
    required this.id,
    required this.name,
    required this.avatar,
    required this.title,
    required this.description,
    required this.url,
    this.processedAvatar = '',
  });

  VideoCreator copyWith({
    String? id,
    String? name,
    String? avatar,
    String? title,
    String? description,
    String? url,
    String? processedAvatar,
  }) {
    return VideoCreator(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      processedAvatar: processedAvatar ?? this.processedAvatar,
    );
  }

  factory VideoCreator.fromJson(Map<String, dynamic> json) {
    return VideoCreator(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'title': title,
      'description': description,
      'url': url,
    };
  }
}
