import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'result.screen.dart';
import '../widgets/settings_icon_button.dart';
import '../services/sound_service.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String categoryName;
  final String difficulty;
  final int questionCount;
  final String nickname;

  const QuizScreen({
    super.key,
    required this.category,
    required this.categoryName,
    required this.difficulty,
    required this.questionCount,
    required this.nickname,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool? isCorrect;
  Timer? timer;
  int timeLeft = 30;
  List<String> currentAnswers = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  Future<void> fetchQuestions() async {
    final url = 'https://opentdb.com/api.php?amount=${widget.questionCount}'
        '&category=${widget.category}&difficulty=${widget.difficulty}&type=multiple';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body)['results'];
        if (questions.isNotEmpty) {
          prepareAnswersForCurrentQuestion();
        }
      });
    }
  }

  void prepareAnswersForCurrentQuestion() {
    if (questions.isEmpty) return;

    final question = questions[currentQuestionIndex];
    currentAnswers = [
      ...List<String>.from(question['incorrect_answers']),
      question['correct_answer'],
    ]..shuffle();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        handleAnswer(null);
      }
    });
  }

  void handleAnswer(String? selectedAnswer) {
    timer?.cancel();
    final correctAnswer = questions[currentQuestionIndex]['correct_answer'];
    setState(() {
      isCorrect = selectedAnswer == correctAnswer;
      if (isCorrect!) {
        score++;
        SoundService().playCorrectSound();
      } else {
        SoundService().playIncorrectSound();
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          timeLeft = 30;
          isCorrect = null;
          prepareAnswersForCurrentQuestion();
          startTimer();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                score: score,
                totalQuestions: questions.length,
                questions: questions,
                nickname: widget.nickname,
                category: widget.category,
                categoryName: widget.categoryName,
                difficulty: widget.difficulty,
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentQuestionIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentQuestionIndex + 1}/${questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          SettingsIconButton(),
        ],
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Progress and Timer Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Progress Bar
                      Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Progression',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: colorScheme.outline.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 16),
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: timeLeft <= 5
                              ? Colors.red.withOpacity(0.1)
                              : colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: timeLeft <= 5
                                ? Colors.red.withOpacity(0.3)
                                : colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              color: timeLeft <= 5
                                  ? Colors.red
                                  : colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Temps restant: $timeLeft secondes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: timeLeft <= 5
                                    ? Colors.red
                                    : colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Question Section (modifiée - icône supprimée)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16), // Juste un espacement
                        Expanded(
                          child: Center(
                            child: Text(
                              question['question'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Answers Section
                Expanded(
                  flex: 2,
                  child: Column(
                    children: currentAnswers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final answer = entry.value;
                      final isCorrectAnswer =
                          answer == question['correct_answer'];

                      Color? buttonColor;
                      if (isCorrect != null) {
                        if (isCorrectAnswer) {
                          buttonColor = Colors.green;
                        } else {
                          buttonColor = Colors.red.withOpacity(0.7);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: buttonColor ?? colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (buttonColor ?? colorScheme.shadow)
                                    .withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: buttonColor != null
                                  ? Colors.transparent
                                  : colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isCorrect == null
                                  ? () {
                                      SoundService().playClickSound();
                                      handleAnswer(answer);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: buttonColor != null
                                            ? Colors.white.withOpacity(0.2)
                                            : colorScheme.primary
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: buttonColor != null
                                                ? Colors.white
                                                : colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        answer,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: buttonColor != null
                                              ? Colors.white
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isCorrect != null && isCorrectAnswer)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    if (isCorrect != null &&
                                        !isCorrectAnswer &&
                                        buttonColor != null)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
