import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import 'logs_screen.dart';
import '../services/log_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _repositoryController;
  late TextEditingController _rawUrlTemplateController;
  String _repoSource = 'gitlab';

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _repositoryController = TextEditingController(text: provider.repositoryUrl);
    _rawUrlTemplateController = TextEditingController(text: provider.rawUrlTemplate);
    _updateRepoSource(provider.repositoryUrl);
  }

  void _updateRepoSource(String url) {
    if (url.contains('gitlab.com')) {
      _repoSource = 'gitlab';
    } else if (url.contains('github.com')) {
      _repoSource = 'github';
    } else {
      _repoSource = 'custom';
    }
  }

  @override
  void dispose() {
    _repositoryController.dispose();
    _rawUrlTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.sc2BgPrimary,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.uniColorTitle,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('语音设置'),
          _buildSwitchItem(
            '启用语音播报',
            provider.voiceEnabled,
            (value) async {
              try {
                LogService.logInfo('${value ? '开启' : '关闭'}语音播报');
                await provider.setVoiceEnabled(value);
                LogService.logInfo('${value ? '开启' : '关闭'}语音播报成功');
              } catch (e) {
                LogService.logError('${value ? '开启' : '关闭'}语音播报失败', e);
              }
            },
          ),
          _buildSliderItem(
            '语音速度',
            provider.voiceSpeed,
            (value) => provider.setVoiceSpeed(value),
          ),
          const SizedBox(height: 24),
          _buildSection('数据源设置'),
          _buildRepoSourceSelector(provider),
          if (_repoSource == 'custom') ...[
            _buildRepositoryInput(provider),
            _buildRawUrlTemplateInput(provider),
          ],
          _buildButton(
            '保存并刷新数据源',
            () async {
              try {
                String newUrl;
                String newRawUrlTemplate;
                if (_repoSource == 'gitlab') {
                  newUrl = 'https://gitlab.com/cairbin/sc2_tactics_store';
                  newRawUrlTemplate = 'https://gitlab.com/api/v4/projects/79923494/repository/files/{filePath}/raw';
                } else if (_repoSource == 'github') {
                  newUrl = 'https://github.com/cairbin/sc2_tactics_store';
                  newRawUrlTemplate = 'https://raw.githubusercontent.com/cairbin/sc2_tactics_store/main/{filePath}';
                } else {
                  newUrl = _repositoryController.text.trim();
                  newRawUrlTemplate = _rawUrlTemplateController.text.trim();
                }
                if (newUrl.isNotEmpty) {
                  LogService.logInfo('修改仓库地址: $newUrl');
                  await provider.setRepositoryUrl(newUrl);
                  await provider.setRawUrlTemplate(newRawUrlTemplate);
                  LogService.logInfo('开始刷新数据源');
                  await provider.refreshAllData();
                  LogService.logInfo('数据源刷新成功');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('数据源已更新'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  LogService.logInfo('仓库地址为空，跳过更新');
                }
              } catch (e) {
                LogService.logError('修改仓库地址或刷新数据源失败', e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('更新失败，请检查网络连接'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSection('调试设置'),
          _buildSwitchItem(
            '启用调试模式',
            provider.debugEnabled,
            (value) async {
              try {
                LogService.logInfo('${value ? '开启' : '关闭'}调试模式');
                await provider.setDebugEnabled(value);
                LogService.logInfo('${value ? '开启' : '关闭'}调试模式成功');
              } catch (e) {
                LogService.logError('${value ? '开启' : '关闭'}调试模式失败', e);
              }
            },
          ),
          if (provider.debugEnabled)
            _buildButton(
              '查看调试日志',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogsScreen()),
                );
              },
            ),
          const SizedBox(height: 24),
          _buildSection('关于'),
          _buildInfoItem('应用版本', '1.0.0'),
          _buildInfoItem('开发者', 'CairBin(Xinyi Liu)'),
          _buildInfoItem('联系方式', 'cairbin@aliyun.com'),
          _buildInfoItem('开源协议', 'Apache License 2.0'),
          _buildLinkItem('GitHub仓库', 'https://github.com/cairbin/SC2Flow'),
          _buildButton(
            '查看第三方库许可协议',
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('第三方库许可协议'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Flutter - BSD 3-Clause License'),
                        SizedBox(height: 8),
                        Text('http - BSD 3-Clause License'),
                        SizedBox(height: 8),
                        Text('shared_preferences - BSD 3-Clause License'),
                        SizedBox(height: 8),
                        Text('provider - MIT License'),
                        SizedBox(height: 8),
                        Text('file_picker - MIT License'),
                        SizedBox(height: 8),
                        Text('url_launcher - BSD 3-Clause License'),
                        SizedBox(height: 8),
                        Text('flutter_tts - MIT License'),
                        SizedBox(height: 8),
                        Text('google_fonts - Apache License 2.0'),
                        SizedBox(height: 16),
                        Text('字体许可协议:'),
                        SizedBox(height: 8),
                        Text('SourceHanSansSC - SIL Open Font License 1.1'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.uniTextColor,
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.sc2AccentPrimary,
            inactiveTrackColor: AppTheme.sc2BgSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(String label, double value, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            onChanged: onChanged,
            min: 0.5,
            max: 1.5,
            divisions: 10,
            activeColor: AppTheme.sc2AccentPrimary,
            inactiveColor: AppTheme.sc2BgSecondary,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('慢', style: TextStyle(fontSize: 12, color: AppTheme.uniTextColorGrey)),
              Text('快', style: TextStyle(fontSize: 12, color: AppTheme.uniTextColorGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepoSourceSelector(AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          const Text(
            '仓库源',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildRadioOption('GitLab（推荐）', 'gitlab'),
          const SizedBox(height: 8),
          _buildRadioOption('GitHub', 'github'),
          const SizedBox(height: 8),
          _buildRadioOption('自定义', 'custom'),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _repoSource = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _repoSource,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _repoSource = newValue;
                });
              }
            },
            activeColor: AppTheme.sc2AccentPrimary,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepositoryInput(AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          const Text(
            '自定义仓库URL',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _repositoryController,
            style: const TextStyle(color: AppTheme.uniTextColor),
            decoration: InputDecoration(
              hintText: 'https://your-custom-repo.com',
              hintStyle: const TextStyle(color: AppTheme.uniTextColorPlaceholder),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppTheme.sc2AccentSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppTheme.sc2AccentPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawUrlTemplateInput(AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          const Text(
            'Raw 文件URL模板',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '使用 {filePath} 作为文件路径的占位符',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rawUrlTemplateController,
            style: const TextStyle(color: AppTheme.uniTextColor),
            decoration: InputDecoration(
              hintText: 'https://example.com/raw/main/{filePath}',
              hintStyle: const TextStyle(color: AppTheme.uniTextColorPlaceholder),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppTheme.sc2AccentSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppTheme.sc2AccentPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Function() onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.sc2AccentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String label, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          try {
            LogService.logInfo('打开链接: $url');
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              LogService.logError('无法打开链接: $url');
            }
          } catch (e) {
            LogService.logError('打开链接失败', e);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.uniTextColor,
              ),
            ),
            Row(
              children: [
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.sc2AccentPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new,
                  color: AppTheme.sc2AccentPrimary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
