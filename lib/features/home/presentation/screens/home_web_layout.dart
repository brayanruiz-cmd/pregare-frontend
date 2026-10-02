import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/organisms/main_shell.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../home/domain/models/daily_verse.dart';
import '../providers/home_provider.dart';

/// 2-Column Desktop/Web layout for Home adhering to PREGARE tokens.
class HomeWebLayout extends StatefulWidget {
  const HomeWebLayout({super.key});

  @override
  State<HomeWebLayout> createState() => _HomeWebLayoutState();
}

class _HomeWebLayoutState extends State<HomeWebLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = context.read<HomeProvider>();
      if (home.state is AsyncInitial) {
        home.loadHomeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final hour = DateTime.now().hour;
    final isEvening = hour >= 19 || hour < 5;

    return Scaffold(
      backgroundColor: PColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEvening, context),
              const SizedBox(height: 36),
              _buildBody(home, isEvening, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEvening, BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final name = auth.currentSession?.user.name ?? onboarding.getDisplayName();

    final greetingText = name != null && name.isNotEmpty
        ? (isEvening ? 'Good evening,\n$name.' : 'Good morning,\n$name.')
        : (isEvening ? 'Good evening.' : 'Good morning.');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingText,
              style: PType.greeting.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              isEvening
                  ? 'Today is complete. Fifteen days now.'
                  : 'A daily space for Scripture, declaration and reflection',
              style: PType.body,
            ),
          ],
        ),
        const Spacer(),
        PStreakPill(streak: isEvening ? 15 : 14),
      ],
    );
  }

  Widget _buildBody(HomeProvider home, bool isEvening, BuildContext context) {
    if (home.state is AsyncLoading || home.state is AsyncInitial) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CircularProgressIndicator(color: PColors.bone)),
      );
    }

    if (home.state is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PEyebrow('Could not load daily updates'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => home.loadHomeData(),
            child: Text('Try again', style: PType.uiStrong),
          ),
        ],
      );
    }

    final homeData = home.state is AsyncData<HomeData>
        ? (home.state as AsyncData<HomeData>).data
        : null;
    final verseText = homeData?.dailyVerse.text ?? '';
    final verseRef = homeData != null
        ? '${homeData.dailyVerse.reference} · ${homeData.dailyVerse.version}'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Left column (58%) ───
        Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's scripture card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: PColors.glassFill,
                  borderRadius: BorderRadius.circular(PRadius.card),
                  border: Border.all(color: PColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PEyebrow("Today's Scripture"),
                    const SizedBox(height: 16),
                    if (verseText.isNotEmpty)
                      Text(
                        '"$verseText"',
                        style: PType.scripture.copyWith(fontSize: 22, height: 1.45),
                      )
                    else
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: PColors.glassFill,
                          borderRadius: BorderRadius.circular(PRadius.chip),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (verseRef.isNotEmpty)
                      Text(verseRef, style: PType.meta.copyWith(color: PColors.bone62)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Faith declarations card
              if (!isEvening)
                PBoneCard(
                  onTap: () => MainShell.setTab(context, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('FAITH DECLARATIONS', style: PType.eyebrow.copyWith(color: PColors.clay)),
                          Text('00 / 04', style: PType.counter),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text('Four declarations,\nprepared for you', style: PType.cardTitle),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: PColors.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, color: PColors.bone, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.card),
                    border: Border.all(color: PColors.glassStroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PEyebrow('Faith Declarations'),
                          Text('04 / 04', style: PType.counter.copyWith(color: PColors.bone62)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"I walk with strength and\nconfidence today."',
                        style: PType.scripture.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Text('Read them again', style: PType.uiStrong.copyWith(color: PColors.bone70)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 36),

        // ─── Right column (42%) ───
        Expanded(
          flex: 42,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PEyebrow('More for you'),
              const SizedBox(height: 16),
              PListRow(
                title: isEvening ? 'Evening Psalm' : 'Finding Peace in Uncertainty',
                meta: isEvening ? 'Psalm 4 · 1 min' : "Today's devotional · 2 min",
                onTap: () => MainShell.setTab(context, 3),
              ),
              PListRow(
                title: 'Read the Bible',
                meta: 'Open Bible library',
                onTap: () => MainShell.setTab(context, 1),
              ),
              PListRow(
                title: 'All Topics',
                meta: 'Explore themes and practice',
                onTap: () => MainShell.setTab(context, 3),
              ),
              PListRow(
                title: 'Your Growth',
                meta: '15 day streak',
                onTap: () => MainShell.setTab(context, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
