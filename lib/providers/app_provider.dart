import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/tactic_store_service.dart';
import '../services/log_service.dart';

class AppProvider extends ChangeNotifier {
  final TacticStoreService _service = TacticStoreService();
  
  int _currentTab = 0;
  int get currentTab => _currentTab;

  String _myFaction = 'P';
  String get myFaction => _myFaction;

  String _enemyFaction = 'P';
  String get enemyFaction => _enemyFaction;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  double _voiceSpeed = 1.0;
  double get voiceSpeed => _voiceSpeed;

  String _repositoryUrl = TacticStoreService.defaultRepo;
  String get repositoryUrl => _repositoryUrl;

  bool _debugEnabled = false;
  bool get debugEnabled => _debugEnabled;

  bool _privacyAccepted = false;
  bool get privacyAccepted => _privacyAccepted;

  bool _eulaAccepted = false;
  bool get eulaAccepted => _eulaAccepted;

  String _rawUrlTemplate = TacticStoreService.defaultRawUrlTemplate;
  String get rawUrlTemplate => _rawUrlTemplate;

  bool _loading = false;
  bool get loading => _loading;

  TacticIndex? _tacticIndex;
  TacticIndex? get tacticIndex => _tacticIndex;

  List<TacticDetail> _localTactics = [];
  List<TacticDetail> get localTactics => _localTactics;

  List<VideoCreator> _videoCreators = [];
  List<VideoCreator> get videoCreators => _videoCreators;

  AppProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _voiceEnabled = await _service.getVoiceEnabled();
    _voiceSpeed = await _service.getVoiceSpeed();
    _repositoryUrl = await _service.getStoreRepo();
    _debugEnabled = await _service.getDebugEnabled();
    _privacyAccepted = await _service.getPrivacyAccepted();
    _eulaAccepted = await _service.getEulaAccepted();
    _rawUrlTemplate = await _service.getRawUrlTemplate();
    await loadLocalTactics();
    notifyListeners();
  }

  void setCurrentTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void setFactions(String my, String enemy) {
    _myFaction = my;
    _enemyFaction = enemy;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    await _service.setVoiceEnabled(enabled);
    notifyListeners();
  }

  Future<void> setVoiceSpeed(double speed) async {
    _voiceSpeed = speed;
    await _service.setVoiceSpeed(speed);
    notifyListeners();
  }

  Future<void> setRepositoryUrl(String url) async {
    _repositoryUrl = url;
    await _service.setStoreRepo(url);
    notifyListeners();
  }

  Future<void> setDebugEnabled(bool enabled) async {
    _debugEnabled = enabled;
    await _service.setDebugEnabled(enabled);
    notifyListeners();
  }

  Future<void> setPrivacyAccepted(bool accepted) async {
    _privacyAccepted = accepted;
    await _service.setPrivacyAccepted(accepted);
    notifyListeners();
  }

  Future<void> setEulaAccepted(bool accepted) async {
    _eulaAccepted = accepted;
    await _service.setEulaAccepted(accepted);
    notifyListeners();
  }

  Future<void> setRawUrlTemplate(String template) async {
    _rawUrlTemplate = template;
    await _service.setRawUrlTemplate(template);
    notifyListeners();
  }

  Future<void> loadTacticIndex() async {
    try {
      _loading = true;
      notifyListeners();
      LogService.logInfo('开始加载战术索引');
      _tacticIndex = await _service.fetchTacticIndex();
      LogService.logInfo('加载战术索引成功');
    } catch (e) {
      LogService.logError('加载战术索引失败', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocalTactics() async {
    try {
      LogService.logInfo('开始加载本地战术');
      _localTactics = await _service.getLocalTactics();
      LogService.logInfo('加载本地战术成功，共 ${_localTactics.length} 个');
    } catch (e) {
      LogService.logError('加载本地战术失败', e);
    } finally {
      notifyListeners();
    }
  }

  Future<bool> downloadTactic(TacticIndexItem tactic) async {
    try {
      LogService.logInfo('开始下载战术: ${tactic.name}, 文件路径: ${tactic.filePath}');
      final detail = await _service.fetchTacticDetail(tactic.filePath);
      if (detail != null) {
        LogService.logInfo('获取战术详情成功: ${detail.name}');
        final success = await _service.saveLocalTactic(detail);
        if (success) {
          LogService.logInfo('保存战术成功: ${detail.name}');
          await loadLocalTactics();
        } else {
          LogService.logError('保存战术失败: ${detail.name}');
        }
        return success;
      } else {
        LogService.logError('获取战术详情失败: ${tactic.name}');
        return false;
      }
    } catch (e) {
      LogService.logError('下载战术失败: ${tactic.name}', e);
      return false;
    }
  }

  Future<bool> importTacticFromJson(String jsonContent) async {
    try {
      LogService.logInfo('开始从JSON导入战术');
      final tactic = await _service.importTacticFromJson(jsonContent);
      if (tactic != null) {
        LogService.logInfo('解析JSON成功: ${tactic.name}');
        final success = await _service.saveLocalTactic(tactic);
        if (success) {
          LogService.logInfo('保存战术成功: ${tactic.name}');
          await loadLocalTactics();
        } else {
          LogService.logError('保存战术失败: ${tactic.name}');
        }
        return success;
      } else {
        LogService.logError('解析JSON失败');
        return false;
      }
    } catch (e) {
      LogService.logError('导入战术失败', e);
      return false;
    }
  }

  Future<TacticDetail?> getLocalTacticById(String tacticId) async {
    final tactic = _localTactics.firstWhere(
      (t) => t.id == tacticId,
      orElse: () => TacticDetail(
        id: '',
        name: '',
        author: '',
        description: '',
        applicableVersion: '',
        tacticType: '',
        tacVersion: 0,
        updateTime: '',
        modName: '',
        modVersion: 0,
        matchup: '',
        actions: [],
        actionsListStr: '',
      ),
    );
    return tactic.id.isEmpty ? null : tactic;
  }

  Future<bool> saveLocalTactic(TacticDetail tactic) async {
    final success = await _service.saveLocalTactic(tactic);
    if (success) {
      await loadLocalTactics();
    }
    return success;
  }

  Future<bool> deleteLocalTactic(String tacticId) async {
    final success = await _service.deleteLocalTactic(tacticId);
    if (success) {
      await loadLocalTactics();
    }
    return success;
  }

  bool isTacticDownloaded(String tacticId) {
    return _localTactics.any((t) => t.id == tacticId);
  }

  Future<void> loadVideoCreators() async {
    _videoCreators = await _service.fetchVideoCreators();
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    try {
      LogService.logInfo('开始刷新所有数据源');
      _loading = true;
      notifyListeners();
      
      await Future.wait([
        loadTacticIndex(),
        loadVideoCreators(),
      ]);
      
      LogService.logInfo('所有数据源刷新成功');
    } catch (e) {
      LogService.logError('刷新数据源失败', e);
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    await _service.clearAllCache();
    _localTactics = [];
    _tacticIndex = null;
    _voiceEnabled = true;
    _voiceSpeed = 1.0;
    _repositoryUrl = TacticStoreService.defaultRepo;
    _privacyAccepted = false;
    _eulaAccepted = false;
    _rawUrlTemplate = TacticStoreService.defaultRawUrlTemplate;
    await _loadInitialData();
  }

  List<TacticIndexItem> get filteredStoreTactics {
    if (_tacticIndex == null) return [];
    final matchup = '${_myFaction.toLowerCase()}v${_enemyFaction.toLowerCase()}';
    var results = _tacticIndex!.tactics
        .where((tactic) => tactic.matchup.toLowerCase() == matchup)
        .toList();

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results = results.where((tactic) =>
          tactic.name.toLowerCase().contains(query) ||
          tactic.author.toLowerCase().contains(query)).toList();
    }

    return results;
  }

  List<TacticDetail> get filteredLocalTactics {
    final matchup = '${_myFaction.toLowerCase()}v${_enemyFaction.toLowerCase()}';
    var results = _localTactics
        .where((tactic) => tactic.matchup.toLowerCase() == matchup)
        .toList();

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results = results.where((tactic) =>
          tactic.name.toLowerCase().contains(query) ||
          tactic.author.toLowerCase().contains(query)).toList();
    }

    return results;
  }
}
