import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/common_widgets.dart';

class _Reward {
  final String name;
  final int points;
  final IconData icon;
  final Color color;
  final String category;

  const _Reward({
    required this.name,
    required this.points,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _availablePoints = 2450;

  static const List<_Reward> _allRewards = [
    _Reward(name: 'Company Hoodie', points: 500, icon: Icons.checkroom_rounded, color: AppColors.primary, category: 'Merchandise'),
    _Reward(name: 'Gift Card \$25', points: 1000, icon: Icons.card_giftcard_rounded, color: Color(0xFFFF6B35), category: 'Digital'),
    _Reward(name: 'Extra Leave Day', points: 2000, icon: Icons.beach_access_rounded, color: Color(0xFF10B981), category: 'Experiences'),
    _Reward(name: 'Team Lunch', points: 800, icon: Icons.restaurant_rounded, color: Color(0xFFF59E0B), category: 'Experiences'),
    _Reward(name: 'Coffee Voucher', points: 200, icon: Icons.coffee_rounded, color: Color(0xFF00ACC1), category: 'Digital'),
    _Reward(name: 'Company Cap', points: 300, icon: Icons.sports_baseball_rounded, color: Color(0xFFEC4899), category: 'Merchandise'),
    _Reward(name: 'Netflix 1 Month', points: 1200, icon: Icons.movie_rounded, color: Color(0xFFEF4444), category: 'Digital'),
    _Reward(name: 'Spa Voucher', points: 1500, icon: Icons.spa_rounded, color: Color(0xFF14B8A6), category: 'Experiences'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Reward> _getFilteredRewards(String category) {
    if (category == 'All') return _allRewards;
    return _allRewards.where((r) => r.category == category).toList();
  }

  void _showRedeemDialog(_Reward reward) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Redeem Reward',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: reward.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(reward.icon, color: reward.color, size: 36),
            ),
            const SizedBox(height: 14),
            Text(reward.name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Cost: ${reward.points} pts',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Your balance: $_availablePoints pts',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: _availablePoints >= reward.points
                ? () {
                    setState(
                        () => _availablePoints -= reward.points);
                    Navigator.pop(context);
                    AppSnackBar.show(
                      context,
                      message: '${reward.name} redeemed successfully!',
                      type: AppSnackBarType.success,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop())
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        if (Navigator.of(context).canPop())
                          const SizedBox(width: 8),
                        Text('Rewards Store',
                            style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded,
                                  color: AppColors.gold, size: 16),
                              const SizedBox(width: 4),
                              Text('$_availablePoints pts',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.white,
                    indicatorWeight: 3,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Merchandise'),
                      Tab(text: 'Experiences'),
                      Tab(text: 'Digital'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RewardsGrid(
                    key: ValueKey('all-$_availablePoints'),
                    rewards: _getFilteredRewards('All'),
                    onRedeem: _showRedeemDialog,
                    userPoints: _availablePoints),
                _RewardsGrid(
                    key: ValueKey('merch-$_availablePoints'),
                    rewards: _getFilteredRewards('Merchandise'),
                    onRedeem: _showRedeemDialog,
                    userPoints: _availablePoints),
                _RewardsGrid(
                    key: ValueKey('exp-$_availablePoints'),
                    rewards: _getFilteredRewards('Experiences'),
                    onRedeem: _showRedeemDialog,
                    userPoints: _availablePoints),
                _RewardsGrid(
                    key: ValueKey('dig-$_availablePoints'),
                    rewards: _getFilteredRewards('Digital'),
                    onRedeem: _showRedeemDialog,
                    userPoints: _availablePoints),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsGrid extends StatelessWidget {
  final List<_Reward> rewards;
  final void Function(_Reward) onRedeem;
  final int userPoints;

  const _RewardsGrid(
      {super.key,
      required this.rewards,
      required this.onRedeem,
      required this.userPoints});

  @override
  Widget build(BuildContext context) {
    final hPad = (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              final childAspectRatio = constraints.maxWidth > 600 ? 0.9 : 0.82;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, i) {
                  final r = rewards[i];
                  final canAfford = userPoints >= r.points;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: r.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(r.icon, color: r.color, size: 32),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(r.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 4),
                        Text('${r.points} pts',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => onRedeem(r),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: canAfford
                                  ? AppColors.primaryGradient
                                  : const LinearGradient(
                                      colors: [Colors.grey, Colors.grey]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Redeem',
                                style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 + i * 50));
                },
              );
            },
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'My Redemptions'),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _RedemptionItem(
                  name: 'Coffee Voucher',
                  date: 'Mar 15, 2026',
                  points: 200,
                  icon: Icons.coffee_rounded,
                  color: const Color(0xFF00ACC1),
                ),
                _RedemptionItem(
                  name: 'Company Cap',
                  date: 'Feb 28, 2026',
                  points: 300,
                  icon: Icons.sports_baseball_rounded,
                  color: const Color(0xFFEC4899),
                ),
                _RedemptionItem(
                  name: 'Gift Card \$25',
                  date: 'Jan 10, 2026',
                  points: 1000,
                  icon: Icons.card_giftcard_rounded,
                  color: const Color(0xFFFF6B35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _RedemptionItem extends StatelessWidget {
  final String name;
  final String date;
  final int points;
  final IconData icon;
  final Color color;

  const _RedemptionItem(
      {required this.name,
      required this.date,
      required this.points,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary)),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('-$points pts',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorAccent)),
        ],
      ),
    );
  }
}

