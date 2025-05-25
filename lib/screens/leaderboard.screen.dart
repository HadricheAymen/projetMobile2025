import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quiz_result.dart';
import '../widgets/settings_icon_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<QuizResult> allResults = [];
  List<QuizResult> filteredResults = [];
  List<dynamic> categories = [];
  List<String> difficulties = ['All', 'easy', 'medium', 'hard'];
  List<int> questionCounts = [0, 5, 10, 15];

  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  int selectedQuestionCount = 0; // 0 means "All"
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Fetch categories from API
    await _fetchCategories();

    // Load quiz results
    await _loadResults();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://opentdb.com/api_category.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = [
            {'id': 0, 'name': 'All'},
            ...data['trivia_categories'],
          ];
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('quiz_results') ?? [];

    final loadedResults = results
        .map((result) => QuizResult.fromJson(json.decode(result)))
        .toList();

    setState(() {
      allResults = loadedResults;
      filteredResults = loadedResults;
    });

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredResults = allResults.where((result) {
        // Apply category filter
        if (selectedCategory != 'All') {
          // Find the category with matching name
          final category = categories.firstWhere(
            (cat) => cat['name'] == selectedCategory,
            orElse: () => {'id': 0, 'name': 'All'},
          );

          // Convert category ID to string for comparison
          final categoryId = category['id'].toString();

          // Compare with the stored category ID
          if (category['name'] != 'All' && result.category != categoryId) {
            return false;
          }
        }

        // Apply difficulty filter
        if (selectedDifficulty != 'All' &&
            result.difficulty != selectedDifficulty) {
          return false;
        }

        // Apply question count filter
        if (selectedQuestionCount != 0 &&
            result.totalQuestions != selectedQuestionCount) {
          return false;
        }

        return true;
      }).toList();

      // Sort by score (highest first)
      filteredResults.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  Future<void> _clearAllResults() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Results'),
        content: const Text(
          'Are you sure you want to delete all quiz results? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear the data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_results');

    // Refresh the screen
    setState(() {
      allResults = [];
      filteredResults = [];
    });

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All quiz results have been cleared')),
      );
    }
  }

  String getCategoryName(String categoryValue) {
    // Si c'est déjà un nom de catégorie (nouveau format), on le retourne directement
    // Si c'est un ID (ancien format), on essaie de le convertir
    try {
      // Vérifier si c'est un nombre (ID)
      final id = int.tryParse(categoryValue);
      if (id != null) {
        final category = categories.firstWhere(
          (cat) => cat['id'] == id,
          orElse: () => {'name': categoryValue},
        );
        return category['name'];
      } else {
        // C'est déjà un nom de catégorie
        return categoryValue;
      }
    } catch (e) {
      return categoryValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          SettingsIconButton(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter controls
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          hint: const Text('Category'),
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['name'],
                              child: Text(
                                category['name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedDifficulty,
                          hint: const Text('Difficulty'),
                          items: difficulties.map((difficulty) {
                            return DropdownMenuItem<String>(
                              value: difficulty,
                              child: Text(
                                difficulty.capitalize(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDifficulty = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: selectedQuestionCount,
                    hint: const Text('Question Count'),
                    items: questionCounts.map((count) {
                      return DropdownMenuItem<int>(
                        value: count,
                        child: Text(
                          count == 0 ? 'All' : count.toString(),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedQuestionCount = value!;
                        _applyFilters();
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Top Scores',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Results list
                  Expanded(
                    child: filteredResults.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            itemCount: filteredResults.length,
                            itemBuilder: (context, index) {
                              final result = filteredResults[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    '${result.nickname}: ${result.score}/${result.totalQuestions}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Category: ${getCategoryName(result.category)}\n'
                                    'Difficulty: ${result.difficulty.capitalize()}\n'
                                    'Date: ${result.timestamp.toLocal().toString().substring(0, 16)}',
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _clearAllResults,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      label: const Text('Reset All Results'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
