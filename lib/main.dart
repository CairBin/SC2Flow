import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/index_screen.dart';
import 'screens/import_screen.dart';
import 'screens/videos_screen.dart';
import 'screens/settings_screen.dart';
import 'services/log_service.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'SC2 Flow - 星程',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  bool _agreementsChecked = false;

  final List<Widget> _pages = [
    const IndexScreen(),
    const ImportScreen(),
    const VideosScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAgreements();
    });
  }

  Future<void> _checkAgreements() async {
    final provider = context.read<AppProvider>();
    if (!provider.eulaAccepted) {
      _showEulaDialog();
    } else if (!provider.privacyAccepted) {
      _showPrivacyPolicyDialog();
    }
    setState(() {
      _agreementsChecked = true;
    });
  }

  void _showEulaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        backgroundColor: AppTheme.sc2BgCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎使用星程！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.uniTextColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '在使用本应用之前，请您需要同意以下协议：',
              style: TextStyle(color: AppTheme.uniTextColor),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://github.com/cairbin/SC2Flow/blob/main/EULA.md');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                '• 最终用户许可协议 (EULA)',
                style: TextStyle(
                  color: AppTheme.sc2AccentPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://github.com/cairbin/SC2Flow/blob/main/PRIVACY_POLICY.md');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                '• 隐私政策',
                style: TextStyle(
                  color: AppTheme.sc2AccentPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '点击"同意"即表示您已阅读并同意以上协议。',
              style: TextStyle(color: AppTheme.uniTextColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              LogService.logInfo('用户拒绝协议，退出应用');
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const Text('不同意'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                LogService.logInfo('用户同意EULA');
                final provider = context.read<AppProvider>();
                await provider.setEulaAccepted(true);
                LogService.logInfo('EULA已保存');
                if (mounted) {
                  Navigator.of(context).pop();
                  if (!provider.privacyAccepted) {
                    _showPrivacyPolicyDialog();
                  }
                }
              } catch (e) {
                LogService.logError('保存EULA失败', e);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sc2AccentPrimary,
            ),
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        backgroundColor: AppTheme.sc2BgCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请确认您已阅读隐私政策',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.uniTextColor,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://github.com/cairbin/SC2Flow/blob/main/PRIVACY_POLICY.md');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                '查看隐私政策',
                style: TextStyle(
                  color: AppTheme.sc2AccentPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '点击"同意"即表示您已阅读并同意隐私政策。',
              style: TextStyle(color: AppTheme.uniTextColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              LogService.logInfo('用户拒绝隐私声明，退出应用');
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const Text('不同意'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                LogService.logInfo('用户同意隐私声明');
                final provider = context.read<AppProvider>();
                await provider.setPrivacyAccepted(true);
                LogService.logInfo('隐私声明已保存');
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                LogService.logError('保存隐私声明失败', e);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sc2AccentPrimary,
            ),
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppTheme.sc2BgSecondary,
      ),
      body: IndexedStack(
        index: _currentPage,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentPage) {
      case 0:
        return '流程训练';
      case 1:
        return '导入流程';
      case 2:
        return '推荐视频';
      case 3:
        return '设置';
      default:
        return '星程';
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.sc2BgSecondary,
        border: Border(
          top: BorderSide(
            color: AppTheme.sc2AccentSecondary,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildTabItem(Icons.sports_esports, '流程训练', 0),
            _buildTabItem(Icons.upload_file, '导入流程', 1),
            _buildTabItem(Icons.video_library, '推荐视频', 2),
            _buildTabItem(Icons.settings, '设置', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    final isActive = index == _currentPage;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          LogService.logInfo('切换到页面: $label');
          setState(() {
            _currentPage = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? AppTheme.sc2AccentPrimary
                    : const Color(0xFF7a7a9a),
                shadows: isActive
                    ? [
                        Shadow(
                          color: AppTheme.sc2AccentPrimary.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? AppTheme.sc2AccentPrimary
                      : const Color(0xFF7a7a9a),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
