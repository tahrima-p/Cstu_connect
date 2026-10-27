import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'verify_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscure = true;
  bool _isLoading = false;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regStudentIdController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _regObscure = true;
  String _selectedDepartment = 'Computer Science & Engineering';
  String _selectedBatch = 'Batch 2022';

  final List<String> _departments = [
    'Computer Science & Engineering',
    'Information & Communication Tech',
    'Business Administration (BBA)',
    'Electrical & Electronic Eng.',
    'Civil Engineering',
    'Mathematics & Basic Sciences',
  ];

  final List<String> _batches = [
    'Batch 2021',
    'Batch 2022',
    'Batch 2023',
    'Batch 2024',
    'Batch 2025',
    'Batch 2026',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regStudentIdController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  bool _isValidCstuEmail(String email) {
    final clean = email.trim().toLowerCase();
    return (clean.endsWith('@student.cstu.ac.bd') || clean.endsWith('@cstu.ac.bd')) && clean.contains('@');
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your university email and password.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final firestoreService = context.read<FirestoreService>();
    final success = await firestoreService.signIn(email, password);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        HapticFeedback.mediumImpact();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in failed. Please check your credentials.'),
            backgroundColor: AppTheme.cstuCrimson,
          ),
        );
      }
    }
  }

  Future<void> _handleStartRegistration() async {
    final name = _regNameController.text.trim();
    final studentId = _regStudentIdController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty || studentId.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all registration fields.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
      return;
    }

    if (!_isValidCstuEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only official @student.cstu.ac.bd university Gmail accounts can join.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: AppTheme.cstuCrimson,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final firestoreService = context.read<FirestoreService>();
    await firestoreService.sendVerificationCode(email);

    setState(() => _isLoading = false);

    if (mounted) {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(
            email: email,
            name: name,
            password: password,
            department: _selectedDepartment,
            batch: _selectedBatch,
            studentId: studentId,
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _loginEmailController.text);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.cstuGold),
              SizedBox(width: 8),
              Text(
                'Reset Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your official CSTU email to receive a password reset link.',
                style: TextStyle(fontSize: 13, color: AppTheme.cstuSlate),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'CSTU Email',
                  hintText: 'student.id@student.cstu.ac.bd',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.cstuSlate)),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailCtrl.text.trim();
                if (email.isNotEmpty) {
                  context.read<FirestoreService>().sendPasswordReset(email);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset instructions sent to $email'),
                      backgroundColor: AppTheme.cstuGold,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cstuGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  void _skipToApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // CSTU Logo Crest & Title
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images.png',
                          width: 84,
                          height: 84,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'CSTU Connect',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.cstuDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Chandpur Science & Technology University',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.cstuSlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Modern Pill Tab Controller
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.cstuDark,
                    unselectedLabelColor: AppTheme.cstuSlate,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    dividerHeight: 0,
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Register'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildSignInTab()
                        : _buildRegisterTab();
                  },
                ),

                const SizedBox(height: 20),

                // Guest Explore Link
                TextButton(
                  onPressed: _skipToApp,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore Campus Quad as Guest',
                        style: TextStyle(
                          color: AppTheme.cstuSlate,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.cstuSlate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back, CSTUian! 🎓',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.cstuDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in with your university Gmail to stay connected',
            style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'University Email',
              hintText: 'student.id@student.cstu.ac.bd',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.cstuGold),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _loginPasswordController,
            obscureText: _loginObscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.cstuGold),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.cstuSlate,
                  size: 20,
                ),
                onPressed: () => setState(() => _loginObscure = !_loginObscure),
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cstuGold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cstuGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Sign In to Campus Quad'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Student Registration 🎓',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.cstuDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registration requires an active @student.cstu.ac.bd Gmail',
            style: TextStyle(fontSize: 12, color: AppTheme.cstuSlate),
          ),
          const SizedBox(height: 18),

          // Full Name
          TextField(
            controller: _regNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Rahim Ahmed',
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.cstuGold),
            ),
          ),

          const SizedBox(height: 12),

          // Student ID
          TextField(
            controller: _regStudentIdController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              hintText: '2022-CSE-001',
              prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.cstuGold),
            ),
          ),

          const SizedBox(height: 12),

          // Official CSTU Email
          TextField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'CSTU Official Gmail',
              hintText: 'student.id@student.cstu.ac.bd',
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.cstuGold),
            ),
          ),

          const SizedBox(height: 12),

          // Department Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.school_outlined, color: AppTheme.cstuGold),
            ),
            isExpanded: true,
            items: _departments.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(
                  dept,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDepartment = val);
            },
          ),

          const SizedBox(height: 12),

          // Batch Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedBatch,
            decoration: const InputDecoration(
              labelText: 'Academic Batch',
              prefixIcon: Icon(Icons.group_outlined, color: AppTheme.cstuGold),
            ),
            items: _batches.map((b) {
              return DropdownMenuItem(
                value: b,
                child: Text(b, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBatch = val);
            },
          ),

          const SizedBox(height: 12),

          // Password
          TextField(
            controller: _regPasswordController,
            obscureText: _regObscure,
            decoration: InputDecoration(
              labelText: 'Create Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.cstuGold),
              suffixIcon: IconButton(
                icon: Icon(
                  _regObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.cstuSlate,
                  size: 20,
                ),
                onPressed: () => setState(() => _regObscure = !_regObscure),
              ),
              helperText: 'Minimum 6 characters',
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleStartRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cstuGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Send Verification Code'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
