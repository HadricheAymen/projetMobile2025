import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home.screen.dart';
import 'quiz_setup.screen.dart';
import '../models/quiz_result.dart';
import '../widgets/settings_icon_button.dart';
import '../services/sound_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final List<dynamic> questions;
  final String nickname;
  final String category;
  final String categoryName;
  final String difficulty;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.nickname,
    required this.category,
    required this.categoryName,
    required this.difficulty,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<QuizResult> pastResults = [];

  @override
  void initState() {
    super.initState();
    _saveResult();
    _loadPastResults();
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    final result = QuizResult(
      nickname: widget.nickname,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      category: widget.categoryName,
      difficulty: widget.difficulty,
      timestamp: DateTime.now(),
    );
    final results = prefs.getStringList('quiz_results') ?? [];
    results.add(json.encode(result.toJson()));
    await prefs.setStringList('quiz_results', results);
  }

  Future<void> _loadPastResults() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('quiz_results') ?? [];
    setState(() {
      pastResults = results
          .map((result) => QuizResult.fromJson(json.decode(result)))
          .toList()
          .reversed
          .toList(); // Show newest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          SettingsIconButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${widget.nickname}\'s Score: ${widget.score}/${widget.totalQuestions}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Past Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pastResults.length,
                itemBuilder: (context, index) {
                  final result = pastResults[index];
                  return ListTile(
                    title: Text(
                      '${result.nickname}: ${result.score}/${result.totalQuestions}',
                    ),
                    subtitle: Text(
                      'Category: ${result.category}, Difficulty: ${result.difficulty}, '
                      '${result.timestamp.toLocal().toString().substring(0, 16)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Question Review:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  return ListTile(
                    title: Text(question['question']),
                    subtitle: Text(
                      'Correct Answer: ${question['correct_answer']}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService().playClickSound();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Accueil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService().playClickSound();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizSetupScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rejouer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
