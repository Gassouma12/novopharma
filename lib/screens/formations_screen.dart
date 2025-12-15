import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novopharma/widgets/bottom_navigation_bar.dart';
import 'package:novopharma/controllers/formation_provider.dart';
import 'package:novopharma/models/blog_post.dart';
import 'package:novopharma/screens/formation_details_screen.dart';
import 'package:novopharma/theme.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({super.key});

  @override
  State<FormationsScreen> createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationScaffoldWrapper(
      currentIndex: 1,
      onTap: (index) {},
      child: Consumer<FormationProvider>(
        builder: (context, formationProvider, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade50,
                    Colors.white,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMesFormationsTab(formationProvider),
                          _buildVideosTab(formationProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightModeColors.novoPharmaBlue,
            LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
            const Color(0xFF1887B8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: LightModeColors.novoPharmaBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles in background
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Formation',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Développez vos compétences',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    Provider.of<FormationProvider>(
                      context,
                      listen: false,
                    ).searchFormations(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une formation...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: LightModeColors.novoPharmaBlue,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LightModeColors.novoPharmaBlue,
                LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Mes Formations'),
            Tab(text: 'Vidéos'),
          ],
        ),
      ),
    );
  }

  Widget _buildMesFormationsTab(FormationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    if (!provider.hasFormations) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.formations.length,
        itemBuilder: (context, index) {
          return _buildFormationCard(provider.formations[index]);
        },
      ),
    );
  }

  Widget _buildVideosTab(FormationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final formationsWithVideos = provider.formations
        .where((formation) => formation.hasVideo)
        .toList();

    if (formationsWithVideos.isEmpty) {
      return _buildEmptyVideoState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: formationsWithVideos.length,
      itemBuilder: (context, index) {
        return _buildVideoCard(formationsWithVideos[index]);
      },
    );
  }

  Widget _buildResourcesTab(FormationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final formationsWithDocs = provider.formations
        .where(
          (formation) => formation.hasPdf || formation.otherFiles.isNotEmpty,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceSection(
          'Fiches produits (PDF)',
          Icons.picture_as_pdf,
          formationsWithDocs,
          'pdf',
        ),
        const SizedBox(height: 16),
        _buildResourceSection(
          'Guides de conformité',
          Icons.book,
          formationsWithDocs,
          'guide',
        ),
        const SizedBox(height: 16),
        _buildResourceSection(
          'Télécopoder',
          Icons.download,
          formationsWithDocs,
          'download',
        ),
      ],
    );
  }

  Widget _buildFormationCard(BlogPost formation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: LightModeColors.novoPharmaBlue.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image with modern overlay
          if (formation.coverImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: formation.coverImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade100],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: LightModeColors.novoPharmaBlue,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade100],
                        ),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: LightModeColors.novoPharmaBlue,
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Modern play button overlay
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: LightModeColors.novoPharmaBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern title with enhanced typography
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: LightModeColors.novoPharmaBlue.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: LightModeColors.novoPharmaBlue.withValues(
                        alpha: 0.2,
                      ),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'FORMATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: LightModeColors.novoPharmaBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  formation.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LightModeColors.dashboardTextPrimary,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Enhanced admin and dates section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: LightModeColors.novoPharmaBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: LightModeColors.novoPharmaBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Formateur',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  formation.author ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: LightModeColors.dashboardTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (formation.startDate != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                formation.formattedStartDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (formation.endDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fin: ${formation.formattedEndDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons - only show if media is available
                _buildActionButtonsSection(formation),

                const SizedBox(height: 16),

                // Modern main action button with gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightModeColors.novoPharmaBlue,
                        LightModeColors.novoPharmaBlue.withValues(alpha: 0.8),
                        const Color(0xFF1887B8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LightModeColors.novoPharmaBlue.withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _startFormation(formation),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Commencer la formation',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.3,
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
    );
  }

  Widget _buildActionButtonsSection(BlogPost formation) {
    // Collect available action buttons
    List<Widget> topRowButtons = [];
    List<Widget> bottomRowButtons = [];

    // Video button (first priority - top row)
    if (formation.hasVideo) {
      topRowButtons.add(
        Expanded(
          child: _buildActionButton(
            'Vidéo explicative',
            Icons.play_circle_outline,
            () => _showVideoDialog(formation),
          ),
        ),
      );
    }

    // PDF button (second priority - top row)
    if (formation.hasPdf) {
      if (topRowButtons.isNotEmpty)
        topRowButtons.add(const SizedBox(width: 12));
      topRowButtons.add(
        Expanded(
          child: _buildActionButton(
            'Fiche PDF',
            Icons.picture_as_pdf_outlined,
            () => _downloadPDF(formation),
          ),
        ),
      );
    }

    // Clinical study button (third priority - bottom row)
    if (formation.hasClinicalStudy) {
      bottomRowButtons.add(
        Expanded(
          child: _buildActionButton(
            'Étude clinique',
            Icons.science_outlined,
            () => _viewClinicalStudy(formation),
          ),
        ),
      );
    }

    // Quiz button (fourth priority - bottom row)
    if (formation.hasQuiz) {
      if (bottomRowButtons.isNotEmpty)
        bottomRowButtons.add(const SizedBox(width: 12));
      bottomRowButtons.add(
        Expanded(
          child: _buildActionButton(
            'Quiz de validation',
            Icons.quiz_outlined,
            () {}, // Disabled
          ),
        ),
      );
    }

    // If no buttons available, return empty container
    if (topRowButtons.isEmpty && bottomRowButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (topRowButtons.isNotEmpty) ...[
          Row(children: topRowButtons),
          if (bottomRowButtons.isNotEmpty) const SizedBox(height: 12),
        ],
        if (bottomRowButtons.isNotEmpty) Row(children: bottomRowButtons),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildVideoCard(BlogPost formation) {
    return GestureDetector(
      onTap: () => _showVideoDialog(formation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.95),
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: LightModeColors.novoPharmaBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Modern video thumbnail with play overlay
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade200],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Cover image or placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: formation.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: formation.coverImage!,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LightModeColors.novoPharmaBlue,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  LightModeColors.novoPharmaBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  LightModeColors.novoPharmaBlue.withValues(
                                    alpha: 0.05,
                                  ),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.video_library,
                              color: LightModeColors.novoPharmaBlue,
                              size: 28,
                            ),
                          ),
                  ),
                  // Modern play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: LightModeColors.novoPharmaBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LightModeColors.novoPharmaBlue.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: LightModeColors.novoPharmaBlue.withValues(
                          alpha: 0.2,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 14,
                          color: LightModeColors.novoPharmaBlue,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'VIDÉO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: LightModeColors.novoPharmaBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: LightModeColors.dashboardTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Par ${formation.author ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSection(
    String title,
    IconData icon,
    List<BlogPost> formations,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: LightModeColors.novoPharmaBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...formations.take(3).map((formation) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formation.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () => _downloadResource(formation, type),
                  child: const Text('Télécharger'),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildErrorState(FormationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Une erreur s\'est produite',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune formation disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les formations apparaîtront ici dès qu\'elles seront publiées',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVideoState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune vidéo disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _startFormation(BlogPost formation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormationDetailsScreen(formation: formation),
      ),
    );
  }

  void _showVideoDialog(BlogPost formation) async {
    if (!formation.hasVideo) {
      _showSnackBar('Aucune vidéo disponible pour cette formation');
      return;
    }

    final videoUrl = formation.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      _showSnackBar('URL de la vidéo non disponible');
      return;
    }

    try {
      final Uri url = Uri.parse(videoUrl);
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Try with inAppBrowserView as fallback
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      print('Error launching video: $e');
      print('Video URL: $videoUrl');
      _showSnackBar('Erreur lors de l\'ouverture de la vidéo');
    }
  }

  void _showVideoDialog_old(BlogPost formation) {
    if (!formation.hasVideo) {
      _showSnackBar('Aucune vidéo disponible pour cette formation');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formation.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Video player area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade900,
                    child: formation.videoUrl != null
                        ? _buildVideoPlayer(formation.videoUrl!)
                        : const Center(
                            child: Text(
                              'Chargement de la vidéo...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (formation.hasQuiz)
                        ElevatedButton.icon(
                          onPressed: null, // Disabled
                          icon: const Icon(Icons.quiz),
                          label: const Text('Quiz de validation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightModeColors.novoPharmaBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.done),
                        label: const Text('Terminer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    // Simple placeholder for video player
    // In a real implementation, you would use video_player package
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_filled,
            size: 80,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Lecteur vidéo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'URL: ${videoUrl.length > 50 ? '${videoUrl.substring(0, 50)}...' : videoUrl}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            '📝 Note: Intégrer video_player package pour lecture vidéo',
            style: TextStyle(color: Colors.orange, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _downloadPDF(BlogPost formation) {
    if (!formation.hasPdf) {
      _showSnackBar('Aucun PDF disponible pour cette formation');
      return;
    }

    final pdfUrl = formation.pdfUrl;
    if (pdfUrl != null) {
      // TODO: Implement PDF download/viewing
      // You can use url_launcher or pdf_viewer packages
      _showSnackBar('Ouverture du PDF: ${formation.title}');
    }
  }

  void _viewClinicalStudy(BlogPost formation) {
    if (!formation.hasClinicalStudy) {
      _showSnackBar('Aucune étude clinique disponible pour cette formation');
      return;
    }

    final studyUrl = formation.clinicalStudyUrl;
    if (studyUrl != null) {
      // TODO: Implement clinical study viewing
      _showSnackBar('Ouverture de l\'étude clinique: ${formation.title}');
    }
  }

  void _startQuiz(BlogPost formation) {
    if (!formation.hasQuiz) {
      _showSnackBar('Aucun quiz disponible pour cette formation');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz de validation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Formation: ${formation.title}'),
              const SizedBox(height: 8),
              Text('Quiz ID: ${formation.linkedQuizId}'),
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
                _navigateToQuiz(formation);
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

  void _navigateToQuiz(BlogPost formation) {
    // TODO: Navigate to quiz screen with linkedQuizId
    _showSnackBar('Navigation vers le quiz: ${formation.linkedQuizId}');
  }

  void _downloadResource(BlogPost formation, String type) {
    // TODO: Download specific resource type
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
