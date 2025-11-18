import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/theme/app_colors.dart';
import 'controllers/auth_controller.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();

  bool _obscurePassword = true;
  int _currentTabIndex = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = ref.read(authProvider.notifier);

  try {
    if (_currentTabIndex == 0) {
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await auth.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nama: _namaController.text.trim(),
        nik: _nikController.text.trim(),
      );
    }
  } on Exception catch (e) {
    // Tangkap Exception yang dilempar dari AuthController
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    // Tangkap semua error lain, termasuk AuthException dari Supabase
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terjadi kesalahan: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final inputTextStyle = Theme.of(context).textTheme.bodyMedium;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.white),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.30,
            child: Container(color: AppColors.primary),
          ),

          Positioned(
            top: screenHeight * 0.15,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor, // responsive card
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthTabSwitcher(
                        currentTabIndex: _currentTabIndex,
                        onTap: (i) {
                          setState(() {
                            _currentTabIndex = i;
                            _formKey.currentState?.reset();
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      if (_currentTabIndex == 1) ...[
                        TextFormField(
                          controller: _namaController,
                          style: inputTextStyle,
                          validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _nikController,
                          style: inputTextStyle,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'NIK tidak boleh kosong';
                            if (v.length < 16) return 'NIK tidak valid';
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'NIK',
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      TextFormField(
                        controller: _emailController,
                        style: inputTextStyle,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                          if (!v.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        style: inputTextStyle,
                        obscureText: _obscurePassword,
                        validator: (v) => v == null || v.isEmpty ? 'Password tidak boleh kosong' : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text(
                                  _currentTabIndex == 0 ? 'Log In' : 'Register',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTabSwitcher extends StatelessWidget {
  final int currentTabIndex;
  final void Function(int) onTap;

  const _AuthTabSwitcher({
    super.key,
    required this.currentTabIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant, // responsive background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Log In',
            isSelected: currentTabIndex == 0,
            onTap: () => onTap(0),
          ),
          _TabButton(
            label: 'Register',
            isSelected: currentTabIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.white
                  : theme.colorScheme.onSurfaceVariant, // responsive text color
            ),
          ),
        ),
      ),
    );
  }
}
