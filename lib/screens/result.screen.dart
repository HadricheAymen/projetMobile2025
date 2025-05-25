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
      pastResults =
          results
              .map((result) => QuizResult.fromJson(json.decode(result)))
              .toList()
              .reversed
              .toList(); // Show newest first
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final isSmallScreen = w < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Résultats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.055),
        ),
        actions: const [SettingsIconButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(w * 0.035),
            child: Column(
              children: [
                // Header Card (keep as is)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.03),
                  margin: EdgeInsets.only(bottom: w * 0.03),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(w * 0.025),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: w * 0.018,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: colorScheme.onPrimary,
                        size: w * 0.08,
                      ),
                      SizedBox(height: w * 0.015),
                      Text(
                        'Bravo, ${widget.nickname} !',
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: w * 0.008),
                      Text(
                        'Score: ${widget.score}/${widget.totalQuestions}',
                        style: TextStyle(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: w * 0.005),
                      Text(
                        'Catégorie: ${widget.categoryName} | Difficulté: ${widget.difficulty}',
                        style: TextStyle(
                          fontSize: w * 0.028,
                          color: colorScheme.onPrimary.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Split the remaining space equally between history and correction
                Expanded(
                  child: Column(
                    children: [
                      // History (top half)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(w * 0.025),
                          margin: EdgeInsets.only(bottom: w * 0.015),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(w * 0.03),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.08),
                                blurRadius: w * 0.018,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historique',
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: w * 0.015),
                              Expanded(
                                child:
                                    pastResults.isEmpty
                                        ? Center(
                                          child: Text(
                                            'Aucun résultat',
                                            style: TextStyle(
                                              fontSize: w * 0.035,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          itemCount: pastResults.length,
                                          itemBuilder: (context, index) {
                                            final result = pastResults[index];
                                            return ListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(
                                                backgroundColor: colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                radius: w * 0.035,
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: w * 0.03,
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                '${result.nickname}: ${result.score}/${result.totalQuestions}',
                                                style: TextStyle(
                                                  fontSize: w * 0.032,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Cat: ${result.category}\nDif: ${result.difficulty}\n${result.timestamp.toLocal().toString().substring(0, 16)}',
                                                style: TextStyle(
                                                  fontSize: w * 0.025,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Correction (bottom half)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(w * 0.025),
                          margin: EdgeInsets.only(top: w * 0.015),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(w * 0.03),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.08),
                                blurRadius: w * 0.018,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correction',
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: w * 0.015),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: widget.questions.length,
                                  itemBuilder: (context, index) {
                                    final question = widget.questions[index];
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        question['question'],
                                        style: TextStyle(
                                          fontSize: w * 0.032,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Bonne réponse: ${question['correct_answer']}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: w * 0.028,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: w * 0.05),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SoundService().playClickSound();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, w * 0.12),
                          backgroundColor: colorScheme.surface,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.03),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: colorScheme.primary,
                              size: w * 0.06,
                            ),
                            SizedBox(width: w * 0.015),
                            Text(
                              'Accueil',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
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
                          minimumSize: Size(0, w * 0.12),
                          backgroundColor: colorScheme.primary,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(w * 0.03),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: colorScheme.onPrimary,
                              size: w * 0.06,
                            ),
                            SizedBox(width: w * 0.015),
                            Text(
                              'Rejouer',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
