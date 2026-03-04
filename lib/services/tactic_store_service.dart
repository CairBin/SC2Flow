import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class TacticStoreService {
  static const String defaultRepo = 'https://gitlab.com/cairbin/sc2_tactics_store';
  static const String gitLabRepo = 'https://gitlab.com/cairbin/sc2_tactics_store';
  static const String gitHubRepo = 'https://github.com/cairbin/sc2_tactics_store';
  static const String storageKeyLocalTactics = 'localTactics';
  static const String storageKeyStoreRepo = 'storeRepo';
  static const String storageKeyVoiceEnabled = 'voiceEnabled';
  static const String storageKeyVoiceSpeed = 'voiceSpeed';
  static const String storageKeyDebugEnabled = 'debugEnabled';
  static const String storageKeyPrivacyAccepted = 'privacyAccepted';
  static const String storageKeyEulaAccepted = 'eulaAccepted';
  static const String storageKeyRawUrlTemplate = 'rawUrlTemplate';
  static const String defaultRawUrlTemplate = '';

  Future<String> getStoreRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageKeyStoreRepo) ?? defaultRepo;
  }

  Future<void> setStoreRepo(String repo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyStoreRepo, repo);
  }

  Future<bool> getVoiceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(storageKeyVoiceEnabled) ?? true;
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKeyVoiceEnabled, enabled);
  }

  Future<double> getVoiceSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(storageKeyVoiceSpeed) ?? 0.8;
  }

  Future<void> setVoiceSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(storageKeyVoiceSpeed, speed);
  }

  Future<bool> getDebugEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(storageKeyDebugEnabled) ?? false;
  }

  Future<void> setDebugEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKeyDebugEnabled, enabled);
  }

  Future<bool> getPrivacyAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(storageKeyPrivacyAccepted) ?? false;
  }

  Future<void> setPrivacyAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKeyPrivacyAccepted, accepted);
  }

  Future<bool> getEulaAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(storageKeyEulaAccepted) ?? false;
  }

  Future<void> setEulaAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKeyEulaAccepted, accepted);
  }

  Future<String> getRawUrlTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageKeyRawUrlTemplate) ?? defaultRawUrlTemplate;
  }

  Future<void> setRawUrlTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyRawUrlTemplate, template);
  }

  String _getRawFileUrl(String repoUrl, String filePath, {String? rawUrlTemplate}) {
    if (repoUrl.contains('github.com')) {
      String rawUrl = repoUrl.replaceFirst('github.com', 'raw.githubusercontent.com');
      if (!rawUrl.endsWith('/')) {
        rawUrl += '/';
      }
      rawUrl += 'main/';
      return rawUrl + filePath;
    } else if (repoUrl.contains('gitlab.com')) {
      final encodedPath = Uri.encodeComponent(filePath);
      return 'https://gitlab.com/api/v4/projects/79923494/repository/files/$encodedPath/raw';
    }

    final template = rawUrlTemplate ?? '';
    if (template.isNotEmpty) {
      return template.replaceAll('{filePath}', filePath);
    }
    return repoUrl + (repoUrl.endsWith('/') ? '' : '/') + filePath;
  }

  Future<String> getAssetUrl(String filePath, {String? repoUrl, String? rawUrlTemplate}) async {
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    final repo = repoUrl ?? await getStoreRepo();
    final template = rawUrlTemplate ?? await getRawUrlTemplate();
    return _getRawFileUrl(repo, filePath, rawUrlTemplate: template);
  }

  Future<String> getAvatarUrl(String avatarPath, {String? repoUrl, String? rawUrlTemplate}) async {
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return avatarPath;
    }
    return await getAssetUrl(avatarPath, repoUrl: repoUrl, rawUrlTemplate: rawUrlTemplate);
  }

  Future<TacticIndex?> fetchTacticIndex({String? repoUrl, String? rawUrlTemplate}) async {
    try {
      final repo = repoUrl ?? await getStoreRepo();
      final template = rawUrlTemplate ?? await getRawUrlTemplate();
      final url = _getRawFileUrl(repo, 'index.json', rawUrlTemplate: template);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TacticIndex.fromJson(data);
      }
      return null;
    } catch (e) {
      print('获取战术索引失败: $e');
      return null;
    }
  }

  Future<TacticDetail?> fetchTacticDetail(String filePath, {String? repoUrl, String? rawUrlTemplate}) async {
    try {
      final repo = repoUrl ?? await getStoreRepo();
      final template = rawUrlTemplate ?? await getRawUrlTemplate();
      final url = _getRawFileUrl(repo, filePath, rawUrlTemplate: template);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TacticDetail.fromJson(data);
      }
      return null;
    } catch (e) {
      print('获取战术详情失败: $e');
      return null;
    }
  }

  Future<TacticDetail?> importTacticFromJson(String jsonContent) async {
    try {
      final data = json.decode(jsonContent);
      return TacticDetail.fromJson(data);
    } catch (e) {
      print('导入战术失败: $e');
      return null;
    }
  }

  Future<bool> saveLocalTactic(TacticDetail tactic) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tactics = await getLocalTactics();
      final existingIndex = tactics.indexWhere((t) => t.id == tactic.id);
      if (existingIndex >= 0) {
        tactics[existingIndex] = tactic;
      } else {
        tactics.add(tactic);
      }
      final tacticsJson = json.encode(tactics.map((t) => t.toJson()).toList());
      await prefs.setString(storageKeyLocalTactics, tacticsJson);
      return true;
    } catch (e) {
      print('保存战术失败: $e');
      return false;
    }
  }

  Future<List<TacticDetail>> getLocalTactics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tacticsJson = prefs.getString(storageKeyLocalTactics);
      if (tacticsJson == null) return [];
      final List<dynamic> decoded = json.decode(tacticsJson);
      return decoded.map((json) => TacticDetail.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('获取本地战术失败: $e');
      return [];
    }
  }

  Future<bool> deleteLocalTactic(String tacticId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tactics = await getLocalTactics();
      final filtered = tactics.where((t) => t.id != tacticId).toList();
      final tacticsJson = json.encode(filtered.map((t) => t.toJson()).toList());
      await prefs.setString(storageKeyLocalTactics, tacticsJson);
      return true;
    } catch (e) {
      print('删除战术失败: $e');
      return false;
    }
  }

  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<List<VideoCreator>> fetchVideoCreators({String? repoUrl, String? rawUrlTemplate}) async {
    try {
      final repo = repoUrl ?? await getStoreRepo();
      final template = rawUrlTemplate ?? await getRawUrlTemplate();
      final url = _getRawFileUrl(repo, 'composer.json', rawUrlTemplate: template);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final creators = data.map((json) => VideoCreator.fromJson(json as Map<String, dynamic>)).toList();
          final processedCreators = <VideoCreator>[];
          for (final creator in creators) {
            final processedAvatar = await getAvatarUrl(creator.avatar, repoUrl: repo, rawUrlTemplate: template);
            processedCreators.add(creator.copyWith(processedAvatar: processedAvatar));
          }
          //print('获取创作者列表成功: $processedCreators');
          return processedCreators;
        }
      }
      return await _getDefaultVideoCreators();
    } catch (e) {
      print('获取创作者列表失败: $e');
      return await _getDefaultVideoCreators();
    }
  }

  Future<List<VideoCreator>> _getDefaultVideoCreators() async {
    // final avatar = 'https://github.com/CairBin/sc2_tactics_store/blob/main/asset/avatar/xiaojin.jpg';
    // final processedAvatar = await getAvatarUrl(avatar);
    // return [
    //   VideoCreator(
    //     id: '1',
    //     name: '小金者',
    //     avatar: avatar,
    //     title: '神族导师',
    //     description: '我就是即时战略高端玩家小金者！',
    //     url: 'https://space.bilibili.com/12610294',
    //     processedAvatar: processedAvatar,
    //   ),
    // ];
    return [];
  }
}
