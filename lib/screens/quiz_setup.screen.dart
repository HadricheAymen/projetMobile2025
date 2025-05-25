import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nickname.screen.dart';
import '../widgets/settings_icon_button.dart';
import '../services/sound_service.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuration du Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.035,
          ),
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
            padding: EdgeInsets.all(isSmallScreen ? 14 : 24),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 18 : 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: isSmallScreen ? 8 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: isSmallScreen ? size.width * 0.08 : 32,
                        color: colorScheme.onPrimary,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuration',
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen ? size.width * 0.05 : 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'Personnalisez votre quiz',
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen ? size.width * 0.035 : 14,
                                color: colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 32),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Category Selection
                        _buildSectionCard(
                          context: context,
                          title: 'Catégorie',
                          icon: Icons.category,
                          isSmallScreen: isSmallScreen,
                          size: size,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 16,
                              vertical: isSmallScreen ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 8 : 12,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              hint: const Text('Sélectionner une catégorie'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen ? size.width * 0.04 : 14,
                                color: colorScheme.onSurface,
                              ),
                              items:
                                  categories.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category['id'].toString(),
                                      child: Text(
                                        category['name'],
                                        style: TextStyle(
                                          fontSize:
                                              isSmallScreen
                                                  ? size.width * 0.04
                                                  : 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                SoundService().playClickSound();
                                setState(() {
                                  selectedCategory = value;
                                  selectedCategoryName =
                                      categories.firstWhere(
                                        (category) =>
                                            category['id'].toString() == value,
                                      )['name'];
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // Difficulty Selection
                        _buildSectionCard(
                          context: context,
                          title: 'Difficulté',
                          icon: Icons.speed,
                          isSmallScreen: isSmallScreen,
                          size: size,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 16,
                              vertical: isSmallScreen ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 8 : 12,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: selectedDifficulty,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen ? size.width * 0.04 : 14,
                                color: colorScheme.onSurface,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'easy',
                                  child: Text('Facile'),
                                ),
                                DropdownMenuItem(
                                  value: 'medium',
                                  child: Text('Moyen'),
                                ),
                                DropdownMenuItem(
                                  value: 'hard',
                                  child: Text('Difficile'),
                                ),
                              ],
                              onChanged: (value) {
                                SoundService().playClickSound();
                                setState(() {
                                  selectedDifficulty = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // Question Count Selection
                        _buildSectionCard(
                          context: context,
                          title: 'Nombre de questions',
                          icon: Icons.quiz,
                          isSmallScreen: isSmallScreen,
                          size: size,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 16,
                              vertical: isSmallScreen ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 8 : 12,
                              ),
                            ),
                            child: DropdownButton<int>(
                              value: selectedQuestionCount,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen ? size.width * 0.04 : 14,
                                color: colorScheme.onSurface,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 5,
                                  child: Text('5 Questions'),
                                ),
                                DropdownMenuItem(
                                  value: 10,
                                  child: Text('10 Questions'),
                                ),
                                DropdownMenuItem(
                                  value: 15,
                                  child: Text('15 Questions'),
                                ),
                              ],
                              onChanged: (value) {
                                SoundService().playClickSound();
                                setState(() {
                                  selectedQuestionCount = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 32),

                        // Next Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                selectedCategory != null
                                    ? () {
                                      SoundService().playClickSound();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => NicknameScreen(
                                                category: selectedCategory!,
                                                categoryName:
                                                    selectedCategoryName,
                                                difficulty: selectedDifficulty,
                                                questionCount:
                                                    selectedQuestionCount,
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(0, isSmallScreen ? 48 : 56),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 12 : 16,
                                ),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 12 : 16,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: isSmallScreen ? 8 : 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: isSmallScreen ? 48 : 56,
                                child: Text(
                                  'Suivant',
                                  style: TextStyle(
                                    fontSize:
                                        isSmallScreen ? size.width * 0.045 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    required bool isSmallScreen,
    required Size size,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: isSmallScreen ? size.width * 0.05 : 20,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? size.width * 0.045 : 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),
          child,
        ],
      ),
    );
  }
}
