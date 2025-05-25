import 'package:flutter/material.dart';
import 'quiz.screen.dart';
import '../widgets/settings_icon_button.dart';

class NicknameScreen extends StatefulWidget {
  final String category;
  final String categoryName;
  final String difficulty;
  final int questionCount;

  const NicknameScreen({
    super.key,
    required this.category,
    required this.categoryName,
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
        _error = 'Veuillez entrer un pseudo';
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizScreen(
              category: widget.category,
              categoryName: widget.categoryName,
              difficulty: widget.difficulty,
              questionCount: widget.questionCount,
              nickname: nickname,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Votre Pseudo',
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
                // Header
                Container(
                  padding: EdgeInsets.all(w * 0.045),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(w * 0.035),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: w * 0.022,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: w * 0.08,
                        color: colorScheme.onPrimary,
                      ),
                      SizedBox(width: w * 0.025),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presque prêt !',
                              style: TextStyle(
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'Entrez votre pseudo pour commencer',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w * 0.05),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Input Field
                      Container(
                        padding: EdgeInsets.all(w * 0.045),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(w * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: w * 0.018,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: colorScheme.primary,
                                  size: w * 0.045,
                                ),
                                SizedBox(width: w * 0.015),
                                Text(
                                  'Pseudo',
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: w * 0.025),
                            TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Entrez votre pseudo...',
                                errorText: _error,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w * 0.025,
                                  ),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w * 0.025,
                                  ),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w * 0.025,
                                  ),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w * 0.025,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    w * 0.025,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: w * 0.03,
                                  vertical: w * 0.03,
                                ),
                              ),
                              onSubmitted: (_) => _startQuiz(),
                              textInputAction: TextInputAction.done,
                              style: TextStyle(fontSize: w * 0.045),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: w * 0.05),

                      // Start Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startQuiz,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, w * 0.13),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.03),
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
                              borderRadius: BorderRadius.circular(w * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: w * 0.022,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: w * 0.13,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: colorScheme.onPrimary,
                                    size: w * 0.06,
                                  ),
                                  SizedBox(width: w * 0.015),
                                  Text(
                                    'Commencer le Quiz',
                                    style: TextStyle(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
