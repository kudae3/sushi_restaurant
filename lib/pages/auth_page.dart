import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/colors.dart';

enum AuthMode { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _auth = AuthService();

  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isBusy) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_mode == AuthMode.login) {
        await _auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/menu');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyAuthMessage(error);
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyFirestoreMessage(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitWithGoogle() async {
    if (_isBusy) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/menu');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyAuthMessage(error);
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyFirestoreMessage(error);
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Unexpected Google sign-in UI failure: $error');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        _errorMessage = 'Google sign-in failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'The password you entered is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'sign_in_canceled':
      case 'canceled':
        return 'Google sign-in was cancelled.';
      case 'sign_in_failed':
        return error.message ?? 'Google sign-in failed. Please try again.';
      case 'sign_in_config_error':
        return error.message ??
            'Google sign-in is not fully configured for this app.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. Please log in using that method first.';
      case 'credential-already-in-use':
        return 'This Google account is already linked to another sign-in method.';
      case 'provider-already-linked':
        return 'This Google account is already linked to your profile.';
      case 'invalid-credential':
        return 'Google credentials are no longer valid. Please try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _friendlyFirestoreMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'We could not save your profile. Please try again.';
      case 'unavailable':
        return 'Profile storage is temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'The request timed out. Please try again.';
      case 'cancelled':
        return 'Signup was cancelled. Please try again.';
      default:
        return error.message ?? 'Could not save your profile. Please try again.';
    }
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _errorMessage = null;
    });
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: secondaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: secondaryColor.withOpacity(0.18), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primaryColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required AuthMode mode,
  }) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: _isBusy ? null : () => _setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: _isBusy ? null : _submitWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(color: secondaryColor.withOpacity(0.16), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isGoogleLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/images/google.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool get _isBusy => _isLoading || _isGoogleLoading;

  @override
  Widget build(BuildContext context) {
    final title = _mode == AuthMode.login ? 'Welcome back' : 'Create account';
    final subtitle = _mode == AuthMode.login
        ? 'Sign in to continue exploring fresh sushi, exclusive offers, and your cart.'
        : 'Join our sushi table and start ordering your favorites in seconds.';
    final actionLabel = _mode == AuthMode.login ? 'Login' : 'Register';
    final helperLabel = _mode == AuthMode.login
        ? "Don't have an account?"
        : 'Already have an account?';
    final helperAction = _mode == AuthMode.login ? 'Register now' : 'Log in';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _backgroundBlob(170, secondaryColor.withOpacity(0.18)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _backgroundBlob(220, primaryColor.withOpacity(0.12)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F2F2),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUSHI MAN',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 28,
                                        color: primaryColor,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      title,
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 26,
                                        color: Colors.black87,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: secondaryColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'lib/images/sushi_2.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: secondaryColor.withOpacity(0.10),
                              ),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                _modeButton(
                                  label: 'Login',
                                  mode: AuthMode.login,
                                ),
                                _modeButton(
                                  label: 'Register',
                                  mode: AuthMode.register,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hintText: 'Email address',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your email.';
                              }
                              if (!text.contains('@')) {
                                return 'Please enter a valid email.';
                              }
                              return null;
                            },
                          ),
                          if (_mode == AuthMode.register) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              decoration: _fieldDecoration(
                                hintText: 'Username',
                                icon: Icons.person_outline,
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (_mode != AuthMode.register) {
                                  return null;
                                }
                                if (text.isEmpty) {
                                  return 'Please choose a username.';
                                }
                                if (text.length < 3) {
                                  return 'Username must be at least 3 characters.';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _mode == AuthMode.register
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (_mode == AuthMode.login) {
                                _submit();
                              } else {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            decoration: _fieldDecoration(
                              hintText: 'Password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                onPressed: _isBusy
                                    ? null
                                    : () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your password.';
                              }
                              if (_mode == AuthMode.register && text.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                          ),
                          if (_mode == AuthMode.register) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: _fieldDecoration(
                                hintText: 'Confirm password',
                                icon: Icons.lock_reset_outlined,
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (_mode != AuthMode.register) {
                                  return null;
                                }
                                if (text.isEmpty) {
                                  return 'Please confirm your password.';
                                }
                                if (text != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.18),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isBusy ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      actionLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: secondaryColor.withOpacity(0.18),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: secondaryColor.withOpacity(0.18),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _googleButton(),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                helperLabel,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: _isBusy
                                    ? null
                                    : () => _setMode(
                                          _mode == AuthMode.login
                                              ? AuthMode.register
                                              : AuthMode.login,
                                        ),
                                style: TextButton.styleFrom(
                                  foregroundColor: secondaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  helperAction,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
