import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../services/log_service.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isImporting = false;

  Future<void> _importTactic() async {
    try {
      LogService.logInfo('开始导入流程文件');
      setState(() {
        _isImporting = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        LogService.logInfo('选择文件: ${file.name}');
        final jsonContent = utf8.decode(file.bytes!);
        LogService.logInfo('文件大小: ${file.size} 字节');
        LogService.logInfo('开始解析JSON文件');
        try {
          // 尝试解析JSON以验证格式
          jsonDecode(jsonContent);
          LogService.logInfo('JSON格式验证成功');
        } catch (e) {
          LogService.logError('JSON格式验证失败', e);
        }

        final provider = context.read<AppProvider>();
        final success = await provider.importTacticFromJson(jsonContent);

        if (success) {
          LogService.logInfo('导入流程成功');
        } else {
          LogService.logError('导入流程失败: 文件格式错误');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '导入成功' : '导入失败，请检查文件格式'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        LogService.logInfo('取消导入文件');
      }
    } catch (e) {
      LogService.logError('导入流程失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入失败，请检查文件'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sc2BgPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.sc2BgCard,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppTheme.sc2AccentSecondary,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '📥',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '导入流程',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.uniColorTitle,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '选择一个JSON格式的流程文件导入到应用中',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.uniTextColorGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _isImporting ? null : _importTactic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sc2AccentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isImporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('选择文件', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 40),
              const Text(
                '注意：导入的文件必须是有效的SC2流程JSON格式',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.uniTextColorGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
