import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class NicknameScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final int questionCount;

  const NicknameScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startQuiz() {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _error = 'Please enter a nickname';
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizScreen(
              category: widget.category,
              difficulty: widget.difficulty,
              questionCount: widget.questionCount,
              nickname: nickname,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Nickname')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nickname',
                errorText: _error,
              ),
              onSubmitted: (_) => _startQuiz(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startQuiz,
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
