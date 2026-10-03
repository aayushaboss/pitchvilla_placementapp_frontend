import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../mockData/mock_profile_options.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../utils/no_orphan.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/autocomplete_field.dart';
import '../../widgets/desktop_field_row.dart';
import '../../widgets/field_label.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/pill_input.dart';
import '../../widgets/responsive_body.dart';

const _qualificationOptions = ['Below 10th', '10th pass', '12th pass', 'Diploma', 'Graduate', 'Postgraduate'];

const _segmentOptions = [
  (Segment.school, 'School'),
  (Segment.ug, 'Undergraduate'),
  (Segment.pg, 'Postgraduate'),
  (Segment.working, 'Working'),
];

/// One screen instead of a per-question quiz: whatever the mocked Google
/// sign-in already handed back (name, city) shows up pre-filled at the top
/// — with a progress bar proving it — and only the handful of things
/// Google could never know (segment, and — for Working — a qualification
/// chip) need actual typing. The "Continue with Email" path lands here too,
/// just without anything pre-filled, using the exact same fields.
///
/// Deliberately minimal: this screen only hard-gates what's needed to
/// personalize the very first feed — name, city, segment, and Working's
/// qualification. Everything else (class/board, college/course/semester,
/// work history) is asked later via the Profile tab's "Basic info"
/// checklist item (profile_readiness.dart), not here.
class MicroProfileScreen extends StatefulWidget {
  const MicroProfileScreen({super.key});

  @override
  State<MicroProfileScreen> createState() => _MicroProfileScreenState();
}

class _MicroProfileScreenState extends State<MicroProfileScreen> {
  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();
  String? _signInMethod;
  // Captured alongside _signInMethod in _hydrateFromUser — the exact
  // signal (already used the same way in otp_screen.dart/booking_screen.
  // dart) for whether this account still needs a phone number asked: a
  // phone sign-up's identifier never contains '@', a Google or email
  // sign-up's always does.
  String _identifier = '';
  String _city = '';
  Segment? _segment;
  String _highestQualification = '';
  bool _loading = false;
  bool _hydrated = false;

  bool get _isSchool => _segment == Segment.school;
  bool get _isWorking => _segment == Segment.working;

  /// Phone sign-up's identifier already is a phone number (auto-filled in
  /// AppState._makeNewUser) — only Google/email sign-ups still need to be
  /// asked here.
  bool get _needsPhone => _identifier.contains('@');

  /// Same 10-15-digit bound already established in login_screen.dart's own
  /// `_valid` getter, reused here rather than inventing a new one.
  bool get _isValidPhone {
    final digits = _phoneController.text.trim();
    return digits.length >= 10 && digits.length <= 15;
  }

  // City is free-text (AutocompleteField), unlike the chip-selected fields
  // below it — trimming before every emptiness check on it (matching how
  // Name already does) stops a whitespace-only entry from counting as
  // "filled" and slipping into the saved profile.
  List<bool> get _filled {
    final base = [
      _nameController.text.trim().isNotEmpty,
      _city.trim().isNotEmpty,
      if (_needsPhone) _isValidPhone,
      _segment != null,
    ];
    if (_isWorking) return [...base, _highestQualification.isNotEmpty];
    return base;
  }

  double get _progress => _filled.where((f) => f).length / _filled.length;

  bool get _canContinue {
    if (_nameController.text.trim().isEmpty || _city.trim().isEmpty || _segment == null) return false;
    if (_needsPhone && !_isValidPhone) return false;
    if (_isWorking) return _highestQualification.isNotEmpty;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  // Runs once real BuildContext/Provider access is available — can't read
  // the just-signed-in user's prefilled name/city from initState.
  void _hydrateFromUser(User? user) {
    if (_hydrated || user == null) return;
    _hydrated = true;
    _nameController.text = user.name ?? '';
    _city = user.city ?? '';
    _phoneController.text = user.phone ?? '';
    _signInMethod = user.signInMethod;
    _identifier = user.identifier;
    // Only restored on a genuine re-visit (segment already set) — treats
    // "Goals has nothing to pop, falls back to context.go('/onboarding/
    // profile')" as resuming an edit, not starting fresh.
    if (user.segment != null) {
      _segment = user.segment;
      _highestQualification = user.highestQualification ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectSegment(Segment s) {
    HapticFeedback.selectionClick();
    setState(() {
      // Switching away from Working leaves the qualification chip selected
      // but hidden — clear it so a change of mind doesn't silently carry a
      // stale value into the submitted profile.
      if (s != Segment.working) _highestQualification = '';
      _segment = s;
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding');
    }
  }

  Future<void> _submit() async {
    if (!_canContinue) return;
    setState(() => _loading = true);
    try {
      final appState = context.read<AppState>();
      final isSchool = _isSchool;
      await appState.updateProfile((current) => current.copyWith(
            name: _nameController.text.trim(),
            city: _city.trim(),
            phone: _needsPhone ? _phoneController.text.trim() : null,
            segment: _segment,
            highestQualification: _isWorking ? _highestQualification : null,
            // School's required profile is complete right here — aptitude is optional after this.
            onboardingComplete: isSchool ? true : null,
            aptitudeSkipped: isSchool ? true : null,
          ));
      if (!mounted) return;
      // School's required profile is now the final onboarding step, so it
      // gets the same completion acknowledgment college/UG/PG/working get
      // after Goals — see onboarding_complete_screen.dart.
      context.go(isSchool ? '/onboarding/complete' : '/college/goals');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// A field's existing FieldLabel + input, unchanged, just grouped so it
  /// can be handed to DesktopFieldRow's left/right slots as one unit.
  Widget _fieldGroup(Widget label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [label, field],
    );
  }

  @override
  Widget build(BuildContext context) {
    _hydrateFromUser(context.read<AppState>().user);
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final percent = (_progress * 100).round();
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: topInset + AppSpacing.sm, left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(onTap: _back, child: const Icon(Ionicons.chevron_back, size: 26, color: AppColors.ink)),
                  Expanded(
                    child: Text(
                      'Complete your profile',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.medium),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm / 2),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: _progress.clamp(0.04, 1.0)),
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: AppSpacing.sm - AppSpacing.xs / 2,
                          backgroundColor: AppColors.gray100,
                          valueColor: const AlwaysStoppedAnimation(AppColors.brand),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('$percent%', style: AppTextStyles.label.copyWith(color: AppColors.ink, fontWeight: AppFontWeight.medium)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                // Generous bottom padding — not just cosmetic. Whenever this
                // screen's content is shorter than the viewport (common,
                // since it's only 3-5 fields), the scroll view has nothing
                // to scroll *to*, so the fixed Continue bar right below reads
                // as glued to the last field with only the old xl (20px) gap.
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tied to signInMethod, not just "is some field
                    // non-empty" — the old check couldn't tell an actually
                    // Google-prefilled field apart from one that happened
                    // to be non-empty for an unrelated reason, so it could
                    // claim a Google pull that never happened. Email/phone
                    // sign-in never gets a city (nothing to derive it
                    // from), so that variant only ever talks about the name.
                    if (_signInMethod == 'google')
                      _AutofillBanner(text: 'Pulled from your Google account — edit anytime.')
                    else if (_signInMethod == 'otp' && _nameController.text.trim().isNotEmpty)
                      _AutofillBanner(text: "We've filled in your name from your email — edit anytime."),
                    if (isTablet)
                      DesktopFieldRow(
                        left: _fieldGroup(
                          const FieldLabel('Full name', tight: true),
                          PillInput(controller: _nameController, placeholder: 'Your name', icon: Ionicons.person_outline, maxLength: 60, onChanged: (_) => setState(() {})),
                        ),
                        right: _fieldGroup(
                          const FieldLabel('City', tight: true),
                          AutocompleteField(
                            value: _city,
                            placeholder: 'e.g. Mumbai',
                            icon: Ionicons.location_outline,
                            options: mockCities,
                            onChanged: (v) => setState(() => _city = v),
                          ),
                        ),
                      )
                    else ...[
                      const FieldLabel('Full name', tight: true),
                      PillInput(controller: _nameController, placeholder: 'Your name', icon: Ionicons.person_outline, maxLength: 60, onChanged: (_) => setState(() {})),
                      const FieldLabel('City'),
                      AutocompleteField(
                        value: _city,
                        placeholder: 'e.g. Mumbai',
                        icon: Ionicons.location_outline,
                        options: mockCities,
                        onChanged: (v) => setState(() => _city = v),
                      ),
                    ],
                    // Only Google/email sign-ups reach here — phone sign-up's
                    // identifier already is the phone number (see
                    // AppState._makeNewUser), so asking again here would be
                    // redundant.
                    if (_needsPhone) ...[
                      const FieldLabel('Phone number'),
                      PillInput(
                        controller: _phoneController,
                        placeholder: '9876543210',
                        icon: Ionicons.call_outline,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const FieldLabel('What stage are you at?'),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _segmentOptions
                          .map((s) => AppChip(label: s.$2, selected: _segment == s.$1, onPressed: () => _selectSegment(s.$1)))
                          .toList(),
                    ),
                    // The one and only follow-up question — everything else
                    // (class/board, college/course/semester, work history)
                    // is asked later via Profile's "Basic info" checklist,
                    // not here. See this class's own doc comment.
                    if (_isWorking) ...[
                      const FieldLabel("What's the highest level you've completed?"),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _qualificationOptions
                            .map((o) => AppChip(
                                  label: o,
                                  selected: _highestQualification == o,
                                  onPressed: () => setState(() => _highestQualification = o),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, bottomInset + AppSpacing.md),
              decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
              child: PillButton(label: 'Continue', onPressed: _canContinue ? _submit : null, loading: _loading, disabled: !_canContinue),
            ),
          ],
        )),
      ),
    );
  }
}

class _AutofillBanner extends StatelessWidget {
  final String text;
  const _AutofillBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        children: [
          const Icon(Ionicons.checkmark_circle, size: 18, color: AppColors.ink),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              noOrphan(text),
              style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontSize: 12, fontWeight: AppFontWeight.medium),
            ),
          ),
        ],
      ),
    );
  }
}
