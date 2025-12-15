import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../widgets/video_player_dialog.dart';
import 'package:novopharma/models/blog_post.dart';
import 'package:novopharma/controllers/quiz_provider.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/screens/quiz_question_screen.dart';
import 'package:novopharma/theme.dart';

// Helper class for formation steps
class FormationStep {
  final String title;
  final String description;
  final IconData icon;
  bool isCompleted;
  final VoidCallback onTap;

  FormationStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
  });
}

class FormationDetailsScreen extends StatefulWidget {
  final BlogPost formation;

  const FormationDetailsScreen({super.key, required this.formation});

  @override
  State<FormationDetailsScreen> createState() => _FormationDetailsScreenState();
}

class _FormationDetailsScreenState extends State<FormationDetailsScreen> {
  int _currentStep = 0;

  // Formation steps with completion tracking
  List<FormationStep> _steps = [];
  List<bool> _stepCompletions = [];

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps = [
      if (widget.formation.hasVideo)
        FormationStep(
          title: 'Vidéos de formation',
          description: 'Regarder les vidéos de la formation',
          icon: Icons.play_circle_outline,
          isCompleted: false,
          onTap: () => _showVideosSection(),
        ),
      FormationStep(
        title: 'Contenu de formation',
        description: 'Lire le contenu détaillé',
        icon: Icons.article_outlined,
        isCompleted: false,
        onTap: () => _showContent(),
      ),
      if (widget.formation.hasQuiz)
        FormationStep(
          title: 'Quiz de validation',
          description: 'Valider vos connaissances',
          icon: Icons.quiz_outlined,
          isCompleted: false,
          onTap: () => _startQuiz(),
        ),
    ];
    _stepCompletions = List.generate(_steps.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LightModeColors.novoPharmaBlue,
                LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Formation',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _shareFormation(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formation Header
            _buildFormationHeader(),

            // Progress Indicator
            _buildProgressIndicator(),

            // Formation Steps
            _buildFormationSteps(),

            // Attachments Section
            _buildAttachmentsSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: LightModeColors.novoPharmaBlue.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              if (widget.formation.coverImage != null)
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LightModeColors.novoPharmaBlue.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.formation.coverImage!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  LightModeColors.novoPharmaBlue,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade100,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Play icon for video indication
                        if (widget.formation.hasVideo)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Title and metadata
              Text(
                widget.formation.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Metadata row with enhanced styling
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LightModeColors.novoPharmaBlue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 16,
                        color: LightModeColors.novoPharmaBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Par ${widget.formation.author ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                    if (widget.formation.startDate != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.formation.formattedStartDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (widget.formation.endDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fin: ${widget.formation.formattedEndDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],

              // Tags
              if (widget.formation.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Catégories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.formation.tags.map((tag) {
                    final colors = [
                      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                    ];
                    final colorIndex = tag.hashCode % colors.length;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors[colorIndex],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: colors[colorIndex][0].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (_steps.isEmpty) return const SizedBox.shrink();

    final completedSteps = _stepCompletions
        .where((completed) => completed)
        .length;
    final progress = completedSteps / _steps.length;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LightModeColors.novoPharmaBlue,
                        LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedSteps/${_steps.length} étapes',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 1.0
                        ? LightModeColors.novoPharmaBlue
                        : Colors.green,
                  ),
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress == 1.0
                  ? 'Formation terminée! 🎉'
                  : '${(progress * 100).toInt()}% complété',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: progress == 1.0
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationSteps() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LightModeColors.novoPharmaBlue,
                        LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Étapes de formation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _steps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = _stepCompletions[index];
                final isActive = index == _currentStep;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: step.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  LightModeColors.novoPharmaBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  LightModeColors.novoPharmaBlue.withValues(
                                    alpha: 0.05,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.grey.shade50, Colors.white],
                              ),
                        border: Border.all(
                          color: isActive
                              ? LightModeColors.novoPharmaBlue.withValues(
                                  alpha: 0.3,
                                )
                              : Colors.grey.shade200,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (isActive)
                            BoxShadow(
                              color: LightModeColors.novoPharmaBlue.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Step Icon with enhanced design
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF48BB78),
                                        Color(0xFF38A169),
                                      ],
                                    )
                                  : isActive
                                  ? LinearGradient(
                                      colors: [
                                        LightModeColors.novoPharmaBlue,
                                        LightModeColors.novoPharmaBlue
                                            .withValues(alpha: 0.8),
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.shade300,
                                        Colors.grey.shade400,
                                      ],
                                    ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isCompleted
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : isActive
                                      ? LightModeColors.novoPharmaBlue
                                            .withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_rounded : step.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Step Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? LightModeColors.novoPharmaBlue
                                        : const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  step.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Terminé',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF38A169),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Arrow Icon with enhanced styling
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? LightModeColors.novoPharmaBlue.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: isActive
                                  ? LightModeColors.novoPharmaBlue
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final attachments = <Map<String, dynamic>>[];

    // Add PDF attachments
    for (final pdfFile in widget.formation.pdfFiles) {
      attachments.add({
        'title': pdfFile.name,
        'type': 'PDF • ${pdfFile.formattedSize}',
        'icon': Icons.picture_as_pdf,
        'color': Colors.red,
        'file': pdfFile,
        'onTap': () => _openPDF(pdfFile),
      });
    }

    // Add image attachments
    for (final imageFile in widget.formation.imageFiles) {
      attachments.add({
        'title': imageFile.name,
        'type': 'IMAGE • ${imageFile.formattedSize}',
        'icon': Icons.image,
        'color': Colors.green,
        'file': imageFile,
        'onTap': () => _openImage(imageFile),
      });
    }

    // Add other file attachments
    for (final otherFile in widget.formation.otherFiles) {
      IconData icon = Icons.attachment;
      Color color = Colors.grey;

      if (otherFile.name.toLowerCase().contains('clinical') ||
          otherFile.name.toLowerCase().contains('study') ||
          otherFile.name.toLowerCase().contains('etude')) {
        icon = Icons.science;
        color = Colors.blue;
      }

      attachments.add({
        'title': otherFile.name,
        'type': '${otherFile.type.toUpperCase()} • ${otherFile.formattedSize}',
        'icon': icon,
        'color': color,
        'file': otherFile,
        'onTap': () => _openAttachment(otherFile),
      });
    }

    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade500],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.attachment_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pièces jointes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${attachments.length} fichier${attachments.length > 1 ? 's' : ''} disponible${attachments.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...attachments.map(
              (attachment) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: attachment['onTap'],
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                attachment['color'],
                                (attachment['color'] as Color).withValues(
                                  alpha: 0.8,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (attachment['color'] as Color)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            attachment['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachment['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF2D3748),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (attachment['color'] as Color)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  attachment['type'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: attachment['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.download_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
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
    );
  }

  // Action Methods
  void _showVideosSection() async {
    if (!widget.formation.hasVideo) {
      _showSnackBar('Aucune vidéo disponible pour cette formation');
      return;
    }

    // Check if youtubeVideoUrl is available first
    if (widget.formation.youtubeVideoUrl != null &&
        widget.formation.youtubeVideoUrl!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(widget.formation.youtubeVideoUrl!);
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          // Try with inAppBrowserView as fallback
          await launchUrl(url, mode: LaunchMode.inAppBrowserView);
        }
        _completeStep(0); // Mark video step as completed
        return;
      } catch (e) {
        print('Error launching video: $e');
        _showSnackBar('Erreur lors de l\'ouverture de la vidéo');
        return;
      }
    }

    // Check if there are video files in media array
    final videoFiles = widget.formation.videoFiles;

    // If there's only one video file and it's a YouTube link, launch it directly
    if (videoFiles.length == 1) {
      final videoFile = videoFiles.first;
      if (videoFile.url.contains('youtube.com') ||
          videoFile.url.contains('youtu.be') ||
          videoFile.url.contains('vimeo.com')) {
        try {
          final Uri url = Uri.parse(videoFile.url);
          final launched = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );

          if (!launched) {
            await launchUrl(url, mode: LaunchMode.inAppBrowserView);
          }
          _completeStep(0); // Mark video step as completed
          return;
        } catch (e) {
          print('Error launching video: $e');
          _showSnackBar('Erreur lors de l\'ouverture de la vidéo');
          return;
        }
      }
    }

    // If multiple videos or non-YouTube videos, show the modal

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LightModeColors.novoPharmaBlue,
                        LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.video_library,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Vidéos de formation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: videoFiles.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.formation.coverImage != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.formation.coverImage!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: double.infinity,
                                        height: 150,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.video_library),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.video_library,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    Text(
                                      videoFiles[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      videoFiles[index].formattedSize,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _playVideo(videoFiles[index]),
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 24,
                                        ),
                                        label: const Text(
                                          'Regarder la vidéo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              LightModeColors.novoPharmaBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 24,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ), // ListView.builder
                  ), // Padding
                ), // Expanded
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _completeStep(0); // Mark video step as completed
    });
  }

  void _playVideo(MediaFile videoFile) async {
    Navigator.pop(context);

    try {
      // Check if it's a YouTube or Vimeo URL (open externally)
      if (videoFile.url.contains('youtube.com') ||
          videoFile.url.contains('youtu.be') ||
          videoFile.url.contains('vimeo.com')) {
        final Uri videoUri = Uri.parse(videoFile.url);
        final launched = await launchUrl(
          videoUri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          // Try with inAppBrowserView as fallback
          await launchUrl(videoUri, mode: LaunchMode.inAppBrowserView);
        }
        return;
      }

      // For direct video files, use in-app video player
      _showVideoPlayer(videoFile);
    } catch (e) {
      _showSnackBar('Erreur lors de la lecture de la vidéo');
    }
  }

  void _showVideoPlayer(MediaFile videoFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog.fullscreen(
        child: VideoPlayerDialog(
          videoUrl: videoFile.url,
          videoTitle: videoFile.name,
          onClose: () {
            Navigator.pop(context);
            _completeStep(0); // Mark video step as completed
          },
        ),
      ),
    );
  }

  void _showContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.formation.title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(child: Text(widget.formation.content)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeStep(
                _steps.indexWhere((s) => s.title == 'Contenu de formation'),
              );
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    if (!widget.formation.hasQuiz) {
      _showSnackBar('Aucun quiz disponible pour cette formation');
      return;
    }

    // Navigate to quiz screen with linkedQuizId
    // For now, show confirmation dialog with proper quiz info
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz de validation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Formation: ${widget.formation.title}'),
              const SizedBox(height: 8),
              Text(
                'Quiz: ${widget.formation.linkedQuizId ?? "Quiz de validation"}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Êtes-vous prêt(e) à commencer le quiz de validation ?',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LightModeColors.novoPharmaBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Commencer'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToQuiz() async {
    if (widget.formation.linkedQuizId == null ||
        widget.formation.linkedQuizId!.isEmpty) {
      _showSnackBar('Aucun quiz associé à cette formation');
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get quiz provider and auth provider
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.firebaseUser?.uid;

      if (userId == null) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar('Utilisateur non connecté');
        return;
      }

      // Fetch all quizzes to find the one with matching ID
      await quizProvider.fetchAllQuizzes(userId);

      // Close loading dialog
      Navigator.pop(context);

      // Find the quiz with the matching linkedQuizId
      final quiz = quizProvider.quizzes.firstWhere(
        (q) => q.id == widget.formation.linkedQuizId,
        orElse: () => throw Exception('Quiz non trouvé'),
      );

      // Navigate to quiz question screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizQuestionScreen(quiz: quiz)),
      );

      // If quiz was completed successfully, mark step as complete
      if (result == true) {
        _completeStep(
          _steps.indexWhere((s) => s.title == 'Quiz de validation'),
        );
        _showSnackBar('Quiz terminé avec succès!');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showSnackBar('Quiz non disponible ou introuvable');
    }
  }

  void _openPDF(MediaFile pdfFile) async {
    await _launchFile(pdfFile, 'PDF');
  }

  void _openImage(MediaFile imageFile) async {
    await _launchFile(imageFile, 'image');
  }

  void _openAttachment(MediaFile file) async {
    await _launchFile(file, 'fichier');
  }

  Future<void> _launchFile(MediaFile file, String fileType) async {
    final Uri fileUri = Uri.parse(file.url);
    await _launchUrlWithFallback(fileUri, fileType);
  }

  Future<void> _launchUrlWithFallback(
    Uri uri,
    String contentType, {
    bool isVideo = false,
  }) async {
    try {
      // Special handling for Firebase Storage URLs
      bool isFirebaseStorage =
          uri.host.contains('firebasestorage') ||
          uri.host.contains('googleapis.com');

      // For videos, especially Firebase Storage videos
      if (isVideo) {
        // Firebase Storage videos work better with platform default or browser
        if (isFirebaseStorage) {
          try {
            await launchUrl(
              uri,
              mode: LaunchMode.inAppBrowserView,
              browserConfiguration: const BrowserConfiguration(showTitle: true),
            );
            _showSnackBar('Lecture de la $contentType dans le navigateur');
            return;
          } catch (e) {
            // Fallback silently
          }
        }

        // Try external video player
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            _showSnackBar('Ouverture de la $contentType');
            return;
          }
        } catch (e) {
          // Fallback silently
        }
      }

      // Try external application for any file type
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _showSnackBar(
            'Ouverture du $contentType dans une application externe',
          );
          return;
        }
      } catch (e) {
        // Fallback silently
      }

      // Fallback 1: Try platform default (let system decide)
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          _showSnackBar('Ouverture du $contentType');
          return;
        }
      } catch (e) {
        // Fallback silently
      }

      // Fallback 2: In-app browser (for downloads)
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
          browserConfiguration: const BrowserConfiguration(showTitle: true),
        );
        _showSnackBar('Téléchargement du $contentType en cours...');
        return;
      } catch (e) {
        // Fallback silently
      }

      // Fallback 3: External browser
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSnackBar('Ouverture dans le navigateur...');
        return;
      } catch (e) {
        // Final fallback failed silently
      }

      // If all else fails
      _showSnackBar(
        'Impossible d\'ouvrir le $contentType. Veuillez vérifier vos applications.',
      );
    } catch (e) {
      _showSnackBar('Erreur lors de l\'ouverture du $contentType');
    }
  }

  void _shareFormation() {
    _showSnackBar('Partage de la formation: ${widget.formation.title}');
  }

  void _completeStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < _stepCompletions.length) {
      setState(() {
        _stepCompletions[stepIndex] = true;
        if (stepIndex == _currentStep && _currentStep < _steps.length - 1) {
          _currentStep++;
        }
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: LightModeColors.novoPharmaBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
