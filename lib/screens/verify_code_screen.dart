import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String department;
  final String batch;
  final String studentId;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.department,
    required this.batch,
    required this.studentId,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final code = _currentCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit verification code.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final firestoreService = context.read<FirestoreService>();

    final isValid = await firestoreService.verifyCode(widget.email, code);

    if (!mounted) return;

    if (isValid) {
      final success = await firestoreService.signUp(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        department: widget.department,
        batch: widget.batch,
        studentId: widget.studentId,
      );

      setState(() => _isVerifying = false);

      if (!mounted) return;

      if (success) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to CSTU Connect, ${widget.name}! 🎉'),
            backgroundColor: AppTheme.cstuEmerald,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration error. Please check your credentials.'),
            backgroundColor: AppTheme.cstuCrimson,
          ),
        );
      }
    } else {
      setState(() => _isVerifying = false);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or expired code. Please try again.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    final firestoreService = context.read<FirestoreService>();
    await firestoreService.sendVerificationCode(widget.email);

    _startResendTimer();
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New code sent to ${widget.email}'),
          backgroundColor: AppTheme.cstuGold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.cstuDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // University Crest
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Verify Your CSTU Gmail',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.cstuDark,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppTheme.cstuSlate, height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit confirmation code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cstuDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Demo / Dev Mode Quick Autofill Banner
              Builder(
                builder: (context) {
                  final latestOtp = context.watch<FirestoreService>().getLatestVerificationCode(widget.email) ?? '123456';
                  return InkWell(
                    onTap: () {
                      for (int i = 0; i < 6 && i < latestOtp.length; i++) {
                        _controllers[i].text = latestOtp[i];
                      }
                      HapticFeedback.mediumImpact();
                      _focusNodes[5].requestFocus();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cstuGoldLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cstuGoldBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 18, color: AppTheme.cstuGold),
                          const SizedBox(width: 8),
                          Text(
                            'Testing Code: $latestOtp (Tap to Autofill)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.cstuDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // 6 Digits Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 58,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cstuDark,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty
                                ? AppTheme.cstuGold
                                : AppTheme.borderLight,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.cstuGold,
                            width: 2.2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                            _handleVerify();
                          }
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 36),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cstuGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify & Activate Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend code option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
                  ),
                  GestureDetector(
                    onTap: _resendCountdown == 0 ? _handleResend : null,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend in ${_resendCountdown}s'
                          : 'Resend Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _resendCountdown > 0
                            ? const Color(0xFF94A3B8)
                            : AppTheme.cstuGold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Security notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cstuGoldLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cstuGoldBorder),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppTheme.cstuGold,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This verification protects your student ID from being registered by anyone else.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
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
    );
  }
}
