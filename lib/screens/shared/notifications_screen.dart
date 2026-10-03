import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories.dart';
import '../../models/notification_item.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_body.dart';

// Note: substituted flash_outline for "sparkles" as in value_slides_screen.dart
// — flutter_vector_icons' bundled Ionicons font predates the sparkles glyph.
const _typeIcons = {
  'opportunity': Ionicons.briefcase_outline,
  'application': Ionicons.trophy_outline,
  'course': Ionicons.book_outline,
  'system': Ionicons.flash_outline,
};

/// Mirrors frontend/app/notifications.tsx (Notifications).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Guards the "mark everything read" call below so it only fires once per
  // screen visit — AsyncValueView's builder re-runs on every rebuild once
  // the list has loaded, not just the first time.
  bool _markedRead = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isSchool = appState.user?.segment == Segment.school;
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: topInset + AppSpacing.sm,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/tabs'),
                    child: const Icon(
                      Ionicons.chevron_back,
                      size: 26,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Notifications',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: AppFontWeight.semibold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView<List<NotificationItem>>(
                loader: () => context.read<Repositories>().notifications.listNotifications(isSchool: isSchool),
                isEmpty: (notifications) => notifications.isEmpty,
                emptyBuilder: (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Ionicons.notifications_off_outline,
                      title: 'No notifications yet',
                      subtitle: "We'll let you know when there's something new.",
                    ),
                  ),
                ),
                builder: (context, notifications) {
                  if (!_markedRead) {
                    _markedRead = true;
                    // Opening this screen is enough to mark everything
                    // currently listed as read — same "seeing it is enough"
                    // convention as markStoryViewed.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      context.read<AppState>().markNotificationsRead(notifications.map((n) => n.id).toList());
                    });
                  }
                  final groups = <String>[];
                  for (final n in notifications) {
                    if (!groups.contains(n.group)) groups.add(n.group);
                  }
                  return ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: groups.map((g) {
                  final items = notifications
                      .where((n) => n.group == g)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                            fontSize: 12,
                            fontWeight: AppFontWeight.medium,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Column(
                            children: items
                                .map(
                                  (n) => Padding(
                                    // The gap between cards has to live
                                    // outside the Material — Material
                                    // paints its background across its
                                    // whole layout box, so a margin on the
                                    // child inside it still gets painted
                                    // over, leaving consecutive cards
                                    // looking fused together with no
                                    // visible seam.
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    child: Material(
                                      color: AppColors.offWhite,
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(AppRadius.xl),
                                        // Tab-shell destinations (e.g. /tabs) must use go(), not push() — the
                                        // shell route isn't designed to be stacked on top of itself and
                                        // renders blank if pushed; regular detail routes push normally.
                                        onTap: n.route == null
                                            ? null
                                            : () => n.route!.startsWith('/tabs')
                                                  ? context.go(n.route!)
                                                  : context.push(n.route!),
                                        child: Container(
                                          // md, not lg — at lg's current 24
                                          // (up from an old 14, per the
                                          // 8pt-grid rebase) this card reads
                                          // noticeably chunkier than a
                                          // typical mobile notification row.
                                          padding: const EdgeInsets.all(
                                            AppSpacing.md,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (!appState.isNotificationRead(n.id))
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors.brand,
                                                        shape: BoxShape.circle,
                                                      ),
                                                )
                                              else
                                                const SizedBox(width: AppSpacing.sm),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.offWhite,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _typeIcons[n.type] ??
                                                      Ionicons
                                                          .notifications_outline,
                                                  size: 18,
                                                  color: AppColors.gray500,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      n.title,
                                                      // medium, not bold — same
                                                      // card-title hierarchy fix
                                                      // as the rest of the app
                                                      // (see opportunity_row.dart).
                                                      style: AppTextStyles
                                                          .bodyLg
                                                          .copyWith(
                                                            color:
                                                                AppColors.ink,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                AppFontWeight
                                                                    .medium,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        n.body,
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color: AppColors
                                                                  .gray500,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (n.route != null)
                                                const Icon(
                                                  Ionicons.chevron_forward,
                                                  size: 18,
                                                  color: AppColors.gray400,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                  );
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}
