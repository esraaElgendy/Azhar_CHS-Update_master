import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/auth_cubit.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import 'login_screen.dart';
import '../../../../features/dashboard/presentation/pages/main_screen.dart';
import '../widgets/language_selector_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    idController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Get current language from app's locale settings
      final currentLocale = Localizations.localeOf(context).languageCode;
      
      context.read<AuthCubit>().register(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            studentId: idController.text.trim(),
            year: yearController.text.trim(),
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

                              CustomTextField(
                                label: l10n.name,
                                controller: nameController,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: l10n.email,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.email; // Should use a proper "Enter email" message
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return "Please enter a valid email (e.g. 15@university.edu)";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: l10n.yourYear,
                                controller: yearController,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: l10n.password,
                                controller: passwordController,
                                isPassword: true,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: l10n.studentId,
                                controller: idController,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _onSignUpPressed,
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
                                            const Icon(Icons.person_add, size: 25),
                                            const SizedBox(width: 10),
                                            Text(
                                              l10n.signUp,
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

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.alreadyHaveAccount,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen()),
                                            );
                                          },
                                    child: Text(
                                      l10n.login,
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
