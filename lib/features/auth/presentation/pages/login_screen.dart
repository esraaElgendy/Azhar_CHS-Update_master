import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/auth_cubit.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import 'sign_up_screen.dart';
import '../../../../features/dashboard/presentation/pages/main_screen.dart';
import '../widgets/language_selector_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Get current language from app's locale settings
      final currentLocale = Localizations.localeOf(context).languageCode;
      
      context.read<AuthCubit>().login(
            studentId: studentIdController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            language: currentLocale,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Load dashboard and navigate to main screen
          context.read<StudentCubit>().loadDashboard();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Language selector at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      LanguageSelectorButton(),
                    ],
                  ),
                  
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AuthHeader(),
                              const SizedBox(height: 30),

                              // Student ID field
                              CustomTextField(
                                label: l10n.studentId,
                                controller: studentIdController,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 16),

                              // Email field
                              CustomTextField(
                                label: l10n.email,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.email;
                                  }
                                  final emailRegex = RegExp(r'^\d+@university\.edu$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return "Invalid email format";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              CustomTextField(
                                label: l10n.password,
                                controller: passwordController,
                                isPassword: true,
                              ),

                              const SizedBox(height: 24),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _onLoginPressed,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.login, size: 25),
                                            const SizedBox(width: 10),
                                            Text(
                                              l10n.login,
                                              style: GoogleFonts.cairo(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.dontHaveAccount,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUpScreen()),
                                            );
                                          },
                                    child: Text(
                                      l10n.signUp,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }
}
