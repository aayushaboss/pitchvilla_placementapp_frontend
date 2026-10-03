import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/mock_auth_repository.dart';
import '../../state/app_state.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../utils/no_orphan.dart';
import '../../widgets/back_chevron.dart';
import '../../widgets/brand.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/pill_input.dart';
import '../../widgets/responsive_body.dart';

enum _LoginMode { phone, email }

/// Mirrors frontend/app/auth/login.tsx (Login).
class LoginScreen extends StatefulWidget {
  /// true = "I already have an account" path → existing-account login.
  final bool returning;

  /// Which field to start on — set when the caller already knows (e.g. the
  /// landing screen's dedicated "Continue with Email" button), so the user
  /// isn't dropped on the phone field and forced to tap again to switch.
  final bool startOnEmail;

  const LoginScreen({super.key, this.returning = false, this.startOnEmail = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  late _LoginMode _mode;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.startOnEmail ? _LoginMode.email : _LoginMode.phone;
  }

  // Was `^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$` — only ever allowed one dot in
  // the domain, rejecting exactly the multi-label college-email formats
  // (.ac.in, .edu.in) this app's own student audience most commonly uses.
  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');

  bool get _valid {
    final value = _controller.text.trim();
    if (_mode == _LoginMode.phone) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      return digits.length >= 10 && digits.length <= 15;
    }
    return _emailPattern.hasMatch(value);
  }

  Future<void> _send() async {
    if (!_valid) {
      setState(() {
        _error = _mode == _LoginMode.phone ? 'Enter a valid number' : 'Enter a valid email';
      });
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final appState = context.read<AppState>();
      // Was the raw controller text — `_valid` above checks a
      // trimmed/digit-stripped value, but this actually-sent identifier
      // used to keep any stray whitespace or padding intact, so it could
      // land in the URL, on the OTP screen, and as the saved-user map key
      // with garbage baked in that "looks the same" as a clean re-entry
      // but isn't.
      final value = _controller.text.trim();
      await appState.requestOtp(value);
      if (!mounted) return;
      final route = Uri(path: '/auth/otp', queryParameters: {
        'identifier': value,
        'returning': widget.returning ? '1' : '0',
      }).toString();
      context.push(route);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == _LoginMode.phone ? _LoginMode.email : _LoginMode.phone;
      _controller.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = AppBreakpoints.of(context) == AppBreakpoint.tablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: ResponsiveBody(maxWidth: isTablet ? 1224 : AppBreakpoints.maxContentWidth, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, topInset + AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BackChevron(color: AppColors.ink, fallbackRoute: '/onboarding'),
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.lg),
                        child: BrandDot(size: AppSpacing.xxxl * 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.ink,
                              fontWeight: AppFontWeight.bold,
                              height: 1.15,
                            ),
                            children: widget.returning
                                ? const [
                                    TextSpan(text: 'Welcome\n'),
                                    TextSpan(text: 'back', style: TextStyle(color: AppColors.ink)),
                                  ]
                                : const [
                                    TextSpan(text: "Let's get\n"),
                                    TextSpan(text: 'you started', style: TextStyle(color: AppColors.ink)),
                                  ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Text(
                          noOrphan(widget.returning
                              ? 'Sign in to continue where you left off.'
                              : "We'll save what you picked and get you matched."),
                          textAlign: TextAlign.left,
                          style: AppTextStyles.bodyLg.copyWith(color: AppColors.gray500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, bottomInset + AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _mode == _LoginMode.phone ? 'Phone number' : 'Email address',
                    style: AppTextStyles.label.copyWith(color: AppColors.ink, fontSize: 16, fontWeight: AppFontWeight.medium),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: PillInput(
                      controller: _controller,
                      onChanged: (_) => setState(() => _error = null),
                      placeholder: _mode == _LoginMode.phone ? '9876543210' : 'you@example.com',
                      keyboardType: _mode == _LoginMode.phone ? TextInputType.number : TextInputType.emailAddress,
                      icon: _mode == _LoginMode.phone ? Ionicons.call_outline : Ionicons.mail_outline,
                      error: _error,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Ionicons.shield_checkmark_outline, size: 14, color: AppColors.gray400),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Stays private — only used for OTP and job updates.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: PillButton(label: 'Send OTP', onPressed: _send, loading: _loading, disabled: !_valid),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border, height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'or',
                            style: AppTextStyles.label.copyWith(color: AppColors.gray400, fontSize: 12),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border, height: 1)),
                      ],
                    ),
                  ),
                  PillButton(
                    label: _mode == _LoginMode.phone ? 'Continue with Email' : 'Continue with Phone',
                    variant: PillVariant.secondary,
                    icon: _mode == _LoginMode.phone ? Ionicons.mail_outline : Ionicons.call_outline,
                    onPressed: _toggleMode,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Text(
                      'Demo: any valid phone or email works — the code is ${MockAuthRepository.demoOtpCode}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(color: AppColors.gray400, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
