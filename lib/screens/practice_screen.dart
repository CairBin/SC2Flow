import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../services/log_service.dart';

class PracticeScreen extends StatefulWidget {
  final TacticDetail tactic;

  const PracticeScreen({Key? key, required this.tactic}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentStep = -1;
  late FlutterTts _flutterTts;
  bool _isTtsInitialized = false;
  int _timer = 0;
  bool _isPaused = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    LogService.logInfo('开始练习流程: ${widget.tactic.name}');
    _initTTS();
    _startTimer();
  }

  Future<void> _initTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('zh-CN');
    final provider = context.read<AppProvider>();
    await _flutterTts.setSpeechRate(provider.voiceSpeed);
    await _flutterTts.setVolume(1.0);
    setState(() {
      _isTtsInitialized = true;
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isPaused && !_isCompleted && mounted) {
        setState(() {
          _timer++;
        });
        _checkTimer();
        _startTimer();
      }
    });
  }

  void _checkTimer() {
    // 根据计时器值更新当前步骤
    for (int i = widget.tactic.actions.length - 1; i >= 0; i--) {
      if (_timer >= widget.tactic.actions[i].time) {
        if (_currentStep != i) {
          setState(() {
            _currentStep = i;
          });
          _announceStep();
        }
        break;
      }
    }
  }

  List<String> _speechQueue = [];
  bool _isSpeaking = false;

  Future<void> _speak(String text) async {
    final provider = context.read<AppProvider>();
    if (_isTtsInitialized && provider.voiceEnabled) {
      _speechQueue.add(text);
      if (!_isSpeaking) {
        _processSpeechQueue();
      }
    }
  }

  Future<void> _processSpeechQueue() async {
    if (_speechQueue.isNotEmpty) {
      _isSpeaking = true;
      final text = _speechQueue.removeAt(0);
      await _flutterTts.setSpeechRate(context.read<AppProvider>().voiceSpeed);
      await _flutterTts.speak(text);
      await Future.delayed(const Duration(seconds: 2)); // 给语音播报留出足够时间
      _isSpeaking = false;
      _processSpeechQueue();
    }
  }

  void _nextStep() {
    if (_currentStep < widget.tactic.actions.length - 1) {
      setState(() {
        _currentStep++;
        _timer = widget.tactic.actions[_currentStep].time;
      });
      LogService.logInfo('切换到下一步: 第${widget.tactic.actions[_currentStep].step}步 - ${widget.tactic.actions[_currentStep].itemAbbr}');
      _announceStep();
    } else {
      _completePractice();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _timer = widget.tactic.actions[_currentStep].time;
      });
      LogService.logInfo('切换到上一步: 第${widget.tactic.actions[_currentStep].step}步 - ${widget.tactic.actions[_currentStep].itemAbbr}');
      _announceStep();
    } else if (_currentStep == 0) {
      setState(() {
        _currentStep = -1;
        _timer = 0;
      });
      LogService.logInfo('返回等待状态');
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (!_isPaused) {
        _startTimer();
        LogService.logInfo('继续练习');
      } else {
        LogService.logInfo('暂停练习');
      }
    });
  }

  void _announceStep() {
    if (_currentStep >= 0 && _currentStep < widget.tactic.actions.length) {
      final step = widget.tactic.actions[_currentStep];
      final announcement = step.number <= 1 ? '${step.itemAbbr}' : '${step.itemAbbr}，×${step.number}';
      LogService.logInfo('播报步骤: $announcement');
      _speak(announcement);
    }
  }

  void _completePractice() {
    setState(() {
      _isCompleted = true;
    });
    LogService.logInfo('完成练习流程: ${widget.tactic.name}');
    _speak('流程练习结束');
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isCompleted) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.sc2BgSecondary,
              title: const Text('终止练习', style: TextStyle(color: AppTheme.uniTextColor)),
              content: const Text('确定要终止当前流程练习吗？', style: TextStyle(color: AppTheme.uniTextColor)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('确定'),
                ),
              ],
            ),
          ) ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.sc2BgPrimary,
        appBar: AppBar(
          title: Text(widget.tactic.name),
          backgroundColor: AppTheme.sc2BgSecondary,
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTimerCard(),
                    const SizedBox(height: 24),
                    _currentStep >= 0 ? _buildStepCard(widget.tactic.actions[_currentStep]) : _buildWaitingCard(),
                    const SizedBox(height: 24),
                    _buildStepsList(),
                    const SizedBox(height: 40),
                    _buildStepNavigation(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    final myFaction = widget.tactic.matchup.isNotEmpty ? widget.tactic.matchup[0].toUpperCase() : 'T';
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.getFactionColor(myFaction),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getFactionColor(myFaction).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _formatTime(_timer),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.getFactionColor(myFaction),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '等待步骤',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.uniColorTitle,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '计时器到点后将自动开始第一步',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / widget.tactic.actions.length;
    return Container(
      width: double.infinity,
      height: 8,
      color: AppTheme.sc2BgSecondary,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.sc2BgSecondary,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sc2AccentPrimary),
      ),
    );
  }

  Widget _buildStepCard(TacticAction action) {
    final myFaction = widget.tactic.matchup.isNotEmpty ? widget.tactic.matchup[0].toUpperCase() : 'T';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '第 ${action.step} 步',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.uniColorTitle,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            action.itemAbbr,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppTheme.getFactionColor(myFaction),
              shadows: [
                Shadow(
                  color: AppTheme.getFactionColor(myFaction).withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoCard('时间', action.time.toString()),
              _buildInfoCard('人口', action.supply),
              if (action.number > 0)
                _buildInfoCard('数量', action.number.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.uniTextColorGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.uniTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.sc2AccentSecondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '步骤列表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.uniColorTitle,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.tactic.actions.map((action) {
            final isCurrentStep = _currentStep >= 0 && action.step == widget.tactic.actions[_currentStep].step;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentStep ? AppTheme.sc2AccentSecondary : AppTheme.sc2BgSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '第 ${action.step} 步: ${action.itemAbbr}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCurrentStep ? Colors.white : AppTheme.uniTextColor,
                        fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_formatTime(action.time)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentStep ? Colors.white : AppTheme.uniTextColorGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepNavigation() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isCompleted ? null : _togglePause,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.sc2BgSecondary,
            foregroundColor: AppTheme.uniTextColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(_isPaused ? '继续' : '暂停', style: const TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: _isCompleted ? null : (_currentStep > 0 ? _previousStep : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.sc2BgSecondary,
            foregroundColor: AppTheme.uniTextColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('上一步', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: _isCompleted ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.sc2AccentPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _currentStep < widget.tactic.actions.length - 1 ? '下一步' : '完成',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
