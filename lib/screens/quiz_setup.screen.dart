import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nickname.screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  List<dynamic> categories = [];
  String? selectedCategory;
  String selectedDifficulty = 'easy';
  int selectedQuestionCount = 5;
  String selectedCategoryName = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://opentdb.com/api_category.php'),
    );
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['trivia_categories'];
        selectedCategory = categories[0]['id'].toString();
        selectedCategoryName = categories[0]['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items:
                  categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text(category['name']),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedCategoryName =
                      categories.firstWhere(
                        (category) => category['id'].toString() == value,
                      )['name'];
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedDifficulty,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: selectedQuestionCount,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 Questions')),
                DropdownMenuItem(value: 10, child: Text('10 Questions')),
                DropdownMenuItem(value: 15, child: Text('15 Questions')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedQuestionCount = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => NicknameScreen(
                          category: selectedCategory!,
                          difficulty: selectedDifficulty,
                          questionCount: selectedQuestionCount,
                        ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
