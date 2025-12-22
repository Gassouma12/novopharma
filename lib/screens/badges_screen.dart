import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novopharma/controllers/badge_provider.dart';
import 'package:novopharma/models/badge.dart' as models;
import 'package:novopharma/widgets/badge_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:novopharma/generated/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  void _showBadgeDetails(BuildContext context, BadgeDisplayInfo badgeInfo) {
    final l10n = AppLocalizations.of(context)!;
    final models.Badge badge = badgeInfo.badge;
    final models.AcquisitionRules? rules = badge.acquisitionRules;

    // Calculate progress details
    final badgesLeft = badge.maxWinners - badge.winnerCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 12),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Image & Title
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: badgeInfo.isAwarded
                                          ? [
                                              const Color(0xFFF59E0B),
                                              const Color(0xFFD97706),
                                            ]
                                          : [
                                              Colors.grey.shade200,
                                              Colors.grey.shade300,
                                            ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (badgeInfo.isAwarded
                                                    ? const Color(0xFFF59E0B)
                                                    : Colors.grey)
                                                .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Image.network(
                                    badge.imageUrl,
                                    height: 80,
                                    width: 80,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.shield_rounded,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  badge.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  badge.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Status Badge
                          if (badgeInfo.isAwarded)
                            _buildAwardedStatus(badgeInfo, context)
                          else
                            _buildProgressStatus(badgeInfo, rules),

                          const SizedBox(height: 24),

                          // Badge Info Cards
                          _buildInfoGrid(badge, rules, badgesLeft, context),

                          const SizedBox(height: 24),

                          // View Rules Button
                          _buildRulesButton(context, badge, rules, l10n),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAwardedStatus(BadgeDisplayInfo badgeInfo, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.badgeEarned,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.awardedOn(
                    DateFormat.yMMMd().format(badgeInfo.userBadge!.awardedAt),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStatus(
    BadgeDisplayInfo badgeInfo,
    models.AcquisitionRules? rules,
  ) {
    if (rules == null) return const SizedBox.shrink();

    final progressPercent = badgeInfo.progress * 100;
    final currentValue = (badgeInfo.progress * rules.targetValue);

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.progress,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${progressPercent.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: badgeInfo.progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1F9BD1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatValue(currentValue, rules.metric),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    _formatValue(rules.targetValue, rules.metric),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(double value, String metric) {
    if (metric == 'revenue') {
      return '${value.toStringAsFixed(2)} TND';
    } else if (metric == 'points') {
      return '${value.toStringAsFixed(0)} pts';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildInfoGrid(
    models.Badge badge,
    models.AcquisitionRules? rules,
    int badgesLeft,
    BuildContext context,
  ) {
    if (rules == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final startDate = DateFormat.yMMMd().format(rules.timeframe.startDate);
    final endDate = DateFormat.yMMMd().format(rules.timeframe.endDate);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.emoji_events_rounded,
                l10n.badgesLeft,
                '$badgesLeft',
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                Icons.flag_rounded,
                l10n.target,
                _formatValue(rules.targetValue, rules.metric),
                const Color(0xFF1F9BD1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Badge Points Card
        if (badge.points != null && badge.points! > 0)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.badgeRewardPoints,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${badge.points} pts',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        if (badge.points != null && badge.points! > 0)
          const SizedBox(height: 12),
        _buildDateRangeCard(startDate, endDate, context),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard(
    String startDate,
    String endDate,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.purple.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventPeriod,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$startDate - $endDate',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesButton(
    BuildContext context,
    models.Badge badge,
    models.AcquisitionRules? rules,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F9BD1).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            _showBadgeRules(context, badge, rules);
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.viewRules,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeRules(
    BuildContext context,
    models.Badge badge,
    models.AcquisitionRules? rules,
  ) {
    if (rules == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BadgeRulesSheet(badge: badge, rules: rules),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.badges,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF9FAFB),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Consumer<BadgeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.badges.isEmpty) {
            return Center(child: Text(l10n.noBadgesAvailable));
          }

          final awardedBadges = provider.badges
              .where((b) => b.isAwarded)
              .toList();
          final lockedBadges = provider.badges
              .where((b) => !b.isAwarded)
              .toList();

          return CustomScrollView(
            slivers: [
              _buildSectionHeader('Awarded (${awardedBadges.length})'),
              _buildGrid(awardedBadges, context),
              _buildSectionHeader('Locked (${lockedBadges.length})'),
              _buildGrid(lockedBadges, context),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<BadgeDisplayInfo> badges, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (badges.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.noBadgesInCategory,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final badgeInfo = badges[index];
          return GestureDetector(
            onTap: () => _showBadgeDetails(context, badgeInfo),
            child: BadgeCard(badgeInfo: badgeInfo),
          );
        }, childCount: badges.length),
      ),
    );
  }
}

class _BadgeRulesSheet extends StatelessWidget {
  final models.Badge badge;
  final models.AcquisitionRules rules;

  const _BadgeRulesSheet({required this.badge, required this.rules});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.rule_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.viewRules,
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRuleSection(
                        Icons.track_changes_rounded,
                        l10n.metric,
                        _getMetricText(rules.metric, l10n),
                        const Color(0xFF1F9BD1),
                      ),
                      const SizedBox(height: 16),
                      _buildRuleSection(
                        Icons.flag_rounded,
                        l10n.target,
                        _formatValue(rules.targetValue, rules.metric),
                        const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 16),
                      _buildScopeSection(l10n),
                      const SizedBox(height: 16),
                      _buildTimeframeSection(l10n),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRuleSection(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                color: Colors.green.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.scope,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rules.scope.brands.isNotEmpty) ...[
            _buildScopeItem(l10n.brands, rules.scope.brands.join(', ')),
            const SizedBox(height: 12),
          ],
          if (rules.scope.categories.isNotEmpty) ...[
            _buildScopeItem(l10n.categories, rules.scope.categories.join(', ')),
            const SizedBox(height: 12),
          ],
          if (rules.scope.productIds.isNotEmpty)
            _ProductChipsWidget(productIds: rules.scope.productIds),
        ],
      ),
    );
  }

  Widget _buildScopeItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSection(AppLocalizations l10n) {
    final startDate = DateFormat.yMMMd().format(rules.timeframe.startDate);
    final endDate = DateFormat.yMMMd().format(rules.timeframe.endDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.purple.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventPeriod,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  startDate,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 2,
                      color: Colors.purple.shade300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.to,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 2,
                      color: Colors.purple.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  endDate,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMetricText(String metric, AppLocalizations l10n) {
    switch (metric) {
      case 'points':
        return l10n.loyaltyPoints;
      case 'revenue':
        return l10n.totalRevenue;
      case 'quantity':
        return l10n.quantitySold;
      default:
        return metric;
    }
  }

  String _formatValue(double value, String metric) {
    if (metric == 'revenue') {
      return '${value.toStringAsFixed(2)} TND';
    } else if (metric == 'points') {
      return '${value.toStringAsFixed(0)} pts';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

// Widget to display product chips with expandable view
class _ProductChipsWidget extends StatefulWidget {
  final List<String> productIds;

  const _ProductChipsWidget({required this.productIds});

  @override
  State<_ProductChipsWidget> createState() => _ProductChipsWidgetState();
}

class _ProductChipsWidgetState extends State<_ProductChipsWidget> {
  bool _isExpanded = false;
  Map<String, String> _productNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductNames();
  }

  Future<void> _fetchProductNames() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final Map<String, String> names = {};

      // Fetch product names in batches of 10 (Firestore whereIn limit)
      for (int i = 0; i < widget.productIds.length; i += 10) {
        final batch = widget.productIds.skip(i).take(10).toList();
        final snapshot = await firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          names[doc.id] = doc.data()['name'] ?? 'Produit ${doc.id}';
        }
      }

      if (mounted) {
        setState(() {
          _productNames = names;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.products,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      );
    }

    final displayedProducts = _isExpanded
        ? widget.productIds
        : widget.productIds.take(3).toList();
    final hasMore = widget.productIds.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.products,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...displayedProducts.map((productId) {
              final productName = _productNames[productId] ?? productId;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.indigo.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        productName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (hasMore)
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.pink.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.more_horiz_rounded,
                        size: 18,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isExpanded
                            ? l10n.showLess
                            : '+${widget.productIds.length - 3}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
