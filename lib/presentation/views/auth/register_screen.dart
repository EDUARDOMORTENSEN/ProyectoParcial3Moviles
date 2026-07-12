import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: _nameController.text.trim(),
      peso: double.parse(_weightController.text),
      altura: double.parse(_heightController.text),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted && authVM.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crear Cuenta',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus datos para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: AppStrings.name,
                    hint: 'Tu nombre completo',
                    prefixIcon: Icons.person_outline,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'ejemplo@correo.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _weightController,
                          label: AppStrings.weight,
                          hint: '70',
                          prefixIcon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          validator: Validators.weight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _heightController,
                          label: AppStrings.height,
                          hint: '170',
                          prefixIcon: Icons.height,
                          keyboardType: TextInputType.number,
                          validator: Validators.height,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthViewModel>(
                    builder: (context, authVM, _) {
                      return CustomButton(
                        text: AppStrings.register,
                        onPressed: authVM.isLoading ? null : _register,
                        isLoading: authVM.isLoading,
                        gradient: AppColors.primaryGradient,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.hasAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          AppStrings.login,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
