import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../services/log_service.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.videoCreators.isEmpty) {
        _loadVideoCreators();
        LogService.logInfo('视频创作者列表为空，开始加载');
      }
    });
  }

  Future<void> _loadVideoCreators() async {
    setState(() {
      _hasError = false;
    });
    try {
      final provider = context.read<AppProvider>();
      await provider.loadVideoCreators();
    } catch (e) {
      LogService.logError('加载视频创作者失败', e);
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法打开链接'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.sc2BgPrimary,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推荐视频',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.uniColorTitle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.sc2AccentPrimary),
                onPressed: () async {
                  await _loadVideoCreators();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.loading) 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.sc2AccentPrimary),
                    SizedBox(height: 16),
                    Text(
                      '加载中...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.sc2AccentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.uniTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请检查网络连接后重试',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.uniTextColorGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _loadVideoCreators();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sc2AccentPrimary,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.videoCreators.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Text(
                  '暂无推荐视频',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.uniTextColorGrey,
                  ),
                ),
              ),
            )
          else
            ...provider.videoCreators.map((creator) => _buildCreatorCard(creator))
        ],
      ),
    );
  }

  Widget _buildCreatorCard(VideoCreator creator) {
    return GestureDetector(
      onTap: () => _launchUrl(creator.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: NetworkImage(creator.processedAvatar.isNotEmpty ? creator.processedAvatar : creator.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.uniColorTitle,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        creator.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.uniTextColorGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: AppTheme.sc2AccentSecondary,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              creator.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.uniTextColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
