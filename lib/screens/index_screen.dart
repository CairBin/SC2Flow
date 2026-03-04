import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/faction_picker.dart';
import '../models/models.dart';
import 'countdown_screen.dart';
import '../services/log_service.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _activeTab = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.tacticIndex == null) {
        provider.loadTacticIndex();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  FactionPicker(
                    myFaction: provider.myFaction,
                    enemyFaction: provider.enemyFaction,
                    onFactionChanged: (my, enemy) {
                      provider.setFactions(my, enemy);
                    },
                  ),
                  _buildSearchBox(provider),
                  _buildMatchupDisplay(provider),
                  if (_activeTab == 0)
                    _buildStoreTab(provider)
                  else
                    _buildLocalTab(provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.sc2BgSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.sc2AccentSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('商店', 0)),
          Expanded(child: _buildTab('我的流程', 1)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.sc2AccentPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? AppTheme.sc2AccentPrimary : AppTheme.uniTextColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(AppProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.uniTextColor, fontSize: 16),
              decoration: const InputDecoration(
                isCollapsed: true,
                hintText: '搜索流程名称或作者...',
                hintStyle: TextStyle(color: AppTheme.uniTextColorPlaceholder, fontSize: 16),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                context.read<AppProvider>().setSearchQuery(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<AppProvider>().setSearchQuery('');
              },
              child: const Text('✕', style: TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchupDisplay(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: provider.myFaction,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getFactionColor(provider.myFaction),
                ),
              ),
              const TextSpan(
                text: ' vs ',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.uniTextColorGrey,
                ),
              ),
              TextSpan(
                text: provider.enemyFaction,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getFactionColor(provider.enemyFaction),
                ),
              ),
              const TextSpan(
                text: ' 战术',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.uniTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTab(AppProvider provider) {
    if (provider.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text(
            '加载中...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.sc2AccentPrimary,
            ),
          ),
        ),
      );
    }

    final tactics = provider.filteredStoreTactics;

    if (tactics.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text(
            '暂无可下载的战术',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: tactics.map((tactic) {
        final isDownloaded = provider.isTacticDownloaded(tactic.id);
        return _buildStoreTacticCard(tactic, isDownloaded, provider);
      }).toList(),
    );
  }

  Widget _buildStoreTacticCard(
    TacticIndexItem tactic,
    bool isDownloaded,
    AppProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tactic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.uniColorTitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.sc2AccentSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '商店',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '作者: ${tactic.author} | 版本: ${tactic.applicableVersion}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'by ${tactic.author}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.uniTextColorGrey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'v${tactic.tacVersion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.uniTextColorGrey,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: isDownloaded
                    ? null
                    : () async {
                        try {
                          LogService.logInfo('开始下载流程: ${tactic.name}, 作者: ${tactic.author}, 版本: ${tactic.tacVersion}');
                          final success = await provider.downloadTactic(tactic);
                          if (success) {
                            LogService.logInfo('下载流程成功: ${tactic.name}');
                          } else {
                            LogService.logError('下载流程失败: ${tactic.name}');
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? '已下载: ${tactic.name}' : '下载失败'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          LogService.logError('下载流程异常: ${tactic.name}', e);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('下载失败，请检查网络连接'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDownloaded ? AppTheme.sc2BgSecondary : null,
                    borderRadius: BorderRadius.circular(6),
                    border: isDownloaded
                        ? Border.all(color: AppTheme.sc2AccentPrimary)
                        : null,
                  ),
                  child: Text(
                    isDownloaded ? '已下载' : '下载',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDownloaded
                          ? AppTheme.sc2AccentPrimary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalTab(AppProvider provider) {
    final tactics = provider.filteredLocalTactics;

    if (tactics.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text(
            '暂无本地战术',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: tactics.map((tactic) {
        return _buildLocalTacticCard(tactic, provider);
      }).toList(),
    );
  }

  Widget _buildLocalTacticCard(
    TacticDetail tactic,
    AppProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tactic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.uniColorTitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.sc2AccentPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '本地',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tactic.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.sc2BgSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tactic.matchup.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.uniTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.sc2BgSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'v${tactic.applicableVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.uniTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.sc2BgSecondary,
                          title: const Text(
                            '删除确认',
                            style: TextStyle(color: AppTheme.uniTextColor),
                          ),
                          content: Text(
                            '确定要删除战术 "${tactic.name}" 吗？此操作不可恢复。',
                            style: const TextStyle(color: AppTheme.uniTextColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  LogService.logInfo('开始删除流程: ${tactic.name}');
                                  Navigator.pop(context);
                                  final success =
                                      await provider.deleteLocalTactic(tactic.id);
                                  if (success) {
                                    LogService.logInfo('删除流程成功: ${tactic.name}');
                                  } else {
                                    LogService.logError('删除流程失败: ${tactic.name}');
                                  }
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('删除成功'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  LogService.logError('删除流程异常: ${tactic.name}', e);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('删除失败，请重试'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.sc2BgSecondary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.sc2AccentSecondary),
                      ),
                      child: const Text(
                        '删除',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.uniTextColor,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        LogService.logInfo('开始练习流程: ${tactic.name}');
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.sc2BgSecondary,
                            title: const Text(
                              '练习确认',
                              style: TextStyle(color: AppTheme.uniTextColor),
                            ),
                            content: Text(
                              '确定要练习 "${tactic.name}" 吗？',
                              style: const TextStyle(color: AppTheme.uniTextColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountdownScreen(
                                        tacticId: tactic.id,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        LogService.logError('练习流程异常: ${tactic.name}', e);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.sc2AccentSecondary,
                            AppTheme.sc2AccentPrimary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '练习',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
