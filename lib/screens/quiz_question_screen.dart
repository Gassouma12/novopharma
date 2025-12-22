import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novopharma/controllers/quiz_provider.dart';
import 'package:novopharma/models/quiz.dart';
import 'package:novopharma/screens/quiz_results_screen.dart';
import 'package:novopharma/services/quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/theme.dart';

class QuizQuestionScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizQuestionScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  late final PageController _pageController;
  final Map<int, List<int>> _selectedAnswers = {};
  late final QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizProvider.startQuiz(widget.quiz, _submitQuiz);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _quizProvider.stopQuiz();
    super.dispose();
  }

  void _nextPage() {
    final state = _quizProvider.activeQuizState;
    if (state == null) return;

    if (state.currentQuestionIndex < widget.quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _quizProvider.nextQuestion();
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() async {
    if (!mounted) return;
    _quizProvider.stopQuiz();

    final userId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).firebaseUser!.uid;
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final selected = _selectedAnswers[i] ?? [];
      final correct = question.correctAnswers;

      selected.sort();
      correct.sort();

      if (const ListEquality().equals(selected, correct)) {
        correctAnswers++;
      }
    }
    // Only award points if all questions are correct
    final pointsEarned = (correctAnswers == widget.quiz.questions.length)
        ? widget.quiz.points
        : 0;
    await QuizService().submitQuiz(
      userId,
      widget.quiz.id,
      correctAnswers,
      pointsEarned,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            quiz: widget.quiz,
            selectedAnswers: _selectedAnswers,
            totalQuestions: widget.quiz.questions.length,
            correctAnswers: correctAnswers,
            pointsEarned: pointsEarned,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final state = quizProvider.activeQuizState;
        if (state == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentQuestion =
            widget.quiz.questions[state.currentQuestionIndex];
        final questionTimeLeft = state.questionTimeLeft;
        final totalQuestionTime = currentQuestion.timeLimitSeconds;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F8FB),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Question ${state.currentQuestionIndex + 1}/${widget.quiz.questions.length}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${(state.quizTimeLeft ~/ 60).toString().padLeft(2, '0')}:${(state.quizTimeLeft % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.quiz.questions.length,
            itemBuilder: (context, index) {
              final question = widget.quiz.questions[index];
              return _buildQuestionPage(
                question,
                index,
                questionTimeLeft,
                totalQuestionTime,
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _nextPage,
            backgroundColor: LightModeColors.novoPharmaBlue,
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildQuestionPage(
    QuizQuestion question,
    int pageIndex,
    int timeLeft,
    int totalTime,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102132),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.multipleAnswersAllowed
                ? 'Select all that apply'
                : 'Select one answer',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: question.options.length,
                    itemBuilder: (context, optionIndex) {
                      final isSelected =
                          _selectedAnswers[pageIndex]?.contains(optionIndex) ??
                          false;
                      return _AnswerCard(
                        text: question.options[optionIndex],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            final currentSelection =
                                _selectedAnswers[pageIndex] ?? [];
                            if (question.multipleAnswersAllowed) {
                              if (isSelected) {
                                currentSelection.remove(optionIndex);
                              } else {
                                currentSelection.add(optionIndex);
                              }
                              _selectedAnswers[pageIndex] = currentSelection;
                            } else {
                              _selectedAnswers[pageIndex] = [optionIndex];
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: totalTime > 0 ? timeLeft / totalTime : 0,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timeLeft > (totalTime * 0.25)
                                  ? LightModeColors.novoPharmaBlue
                                  : Colors.red,
                            ),
                          ),
                        ),
                        Text(
                          '$timeLeft',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102132),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? LightModeColors.novoPharmaBlue.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? LightModeColors.novoPharmaBlue
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.check_circle,
                  color: LightModeColors.novoPharmaBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
