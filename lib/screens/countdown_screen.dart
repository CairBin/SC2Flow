import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import 'practice_screen.dart';

class CountdownScreen extends StatefulWidget {
  final String tacticId;

  const CountdownScreen({Key? key, required this.tacticId}) : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _countdown = 3;
  late TacticDetail _tactic;
  bool _loading = true;
  double _circleSize = 300.0;
  double _borderWidth = 12.0;

  @override
  void initState() {
    super.initState();
    _loadTactic();
  }

  Future<void> _loadTactic() async {
    final provider = context.read<AppProvider>();
    final tactic = await provider.getLocalTacticById(widget.tacticId);
    if (tactic != null) {
      setState(() {
        _tactic = tactic;
        _loading = false;
      });
      _startCountdown();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法加载战术'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startCountdown() {
    // 动画效果
    setState(() {
      _circleSize = 300.0;
      _borderWidth = 12.0;
    });

    // 倒计时逻辑
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
          // 缩小圆圈
          _circleSize -= 60.0;
          _borderWidth -= 2.0;
        });
        if (_countdown > 0) {
          _startCountdown();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeScreen(tactic: _tactic),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.sc2BgPrimary,
        body: const Center(
          child: Text(
            '加载中...',
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.sc2AccentPrimary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.sc2BgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _tactic.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.uniColorTitle,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getFactionColor(_tactic.matchup.isNotEmpty ? _tactic.matchup[0].toUpperCase() : 'T'),
                  width: _borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getFactionColor(_tactic.matchup.isNotEmpty ? _tactic.matchup[0].toUpperCase() : 'T').withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_countdown',
                  style: TextStyle(
                    fontSize: _circleSize * 0.3,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getFactionColor(_tactic.matchup.isNotEmpty ? _tactic.matchup[0].toUpperCase() : 'T'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            const Text(
              '准备开始练习',
              style: TextStyle(
                fontSize: 24,
                color: AppTheme.uniTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
