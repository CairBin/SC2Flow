import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/log_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _logs = await LogService.getLogs();
    } catch (e) {
      print('加载日志失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    try {
      await LogService.clearLogs();
      setState(() {
        _logs = [];
      });
    } catch (e) {
      print('清空日志失败: $e');
    }
  }

  Color _getLogLevelColor(String level) {
    switch (level) {
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
        return Colors.yellow;
      case 'INFO':
        return Colors.green;
      case 'DEBUG':
        return Colors.blue;
      default:
        return AppTheme.uniTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sc2BgPrimary,
      appBar: AppBar(
        title: const Text('调试日志'),
        backgroundColor: AppTheme.sc2BgSecondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '日志记录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.uniTextColor,
                  ),
                ),
                ElevatedButton(
                  onPressed: _clearLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sc2AccentPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('清空日志'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无日志记录',
                          style: TextStyle(color: AppTheme.uniTextColorGrey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final timestamp = DateTime.parse(log['timestamp']);
                          final formattedTime = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
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
                                    Text(
                                      formattedTime,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.uniTextColorGrey,
                                      ),
                                    ),
                                    Text(
                                      log['level'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getLogLevelColor(log['level']),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  log['message'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.uniTextColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}