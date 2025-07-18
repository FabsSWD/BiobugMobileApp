import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/login_params.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Field
            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email o Cédula',
                hintText: 'Ingrese su email o número de cédula',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email o cédula es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Login Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is AuthLoading ? null : _onLoginPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state is AuthLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Forgot Password Link
            TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad en desarrollo'),
                  ),
                );
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.green.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      final params = LoginParams(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      context.read<AuthBloc>().add(AuthLoginEvent(params));
    }
  }
}