import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'result.screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final int questionCount;
  final String nickname;

  const QuizScreen({
    super.key,
    required this.category,
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
  int timeLeft = 10;
  List<String> currentAnswers = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.questionCount}'
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
      if (isCorrect!) score++;
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
              builder:
                  (context) => ResultScreen(
                    score: score,
                    totalQuestions: questions.length,
                    questions: questions,
                    nickname: widget.nickname,
                    category: widget.category,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Time left: $timeLeft seconds'),
            const SizedBox(height: 20),
            Text(question['question'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...currentAnswers.map(
              (answer) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCorrect == null
                            ? null
                            : answer == question['correct_answer']
                            ? Colors.green
                            : Colors.red,
                  ),
                  onPressed:
                      isCorrect == null ? () => handleAnswer(answer) : null,
                  child: Text(answer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
