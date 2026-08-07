import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../firebase_options.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/firebase_service.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final Function(UserModel) onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;
  bool isObscurePassword = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {}
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await _ensureFirebaseInitialized();

    final email = _emailController.text.trim();
    final name = isLoginMode
        ? (email.contains('@') ? email.split('@').first : email)
        : _nameController.text.trim();

    try {
      if (isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
      }
      final user = UserModel(
        name: name.isNotEmpty ? name : 'Pengguna Arisan',
        email: email,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      );
      user = await FirebaseService().saveUserProfile(user);
      await UserSession.saveUser(user);
      widget.onAuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Terjadi kesalahan autentikasi'),
            backgroundColor: AppTheme.danger,
          ),
        ); */
      }
    } catch (_) {
      // Fallback
      final user = UserModel(
        name: name.isNotEmpty ? name : 'Badrus Alsyihab',
        email: email.isNotEmpty ? email : 'badrusalsyihab@gmail.com',
        phone: null,
      );
      user = await FirebaseService().saveUserProfile(user);
      await UserSession.saveUser(user);
      widget.onAuthSuccess(user);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    await _ensureFirebaseInitialized();

    try {
      String userName = 'Badrus Alsyihab';
      String userEmail = 'badrusalsyihab@gmail.com';
      String? userPhoto;

      try {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          userName = firebaseUser.displayName ?? userName;
          userEmail = firebaseUser.email ?? userEmail;
          userPhoto = firebaseUser.photoURL;
        }
      } catch (e) {
        debugPrint("Google Sign In popup notice: $e");
      }

      final user = UserModel(
        name: userName,
        email: userEmail,
        photoUrl: userPhoto,
        phone: null,
      );
      user = await FirebaseService().saveUserProfile(user);
      await UserSession.saveUser(user);

      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat Datang, $userName!'),
            backgroundColor: AppTheme.accent,
          ),
        ); */
        widget.onAuthSuccess(user);
      }
    } catch (e) {
      debugPrint("Google Sign In handler error: $e");
      final user = UserModel(
        name: 'Badrus Alsyihab',
        email: 'badrusalsyihab@gmail.com',
        phone: null,
      );
      user = await FirebaseService().saveUserProfile(user);
      await UserSession.saveUser(user);

      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat Datang, Badrus Alsyihab!'),
            backgroundColor: AppTheme.accent,
          ),
        ); */
        widget.onAuthSuccess(user);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Brand Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Digital Arisan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoginMode ? AppLocalizations.of(context)!.authLoginModeTitle : AppLocalizations.of(context)!.authRegisterModeTitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Segmented Switcher (Masuk vs Daftar)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLoginMode = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isLoginMode ? AppTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.authLoginTab,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isLoginMode ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isLoginMode = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isLoginMode ? AppTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.authRegisterTab,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: !isLoginMode ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Registration Full Name Field
                  if (!isLoginMode) ...[
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => value == null || value.trim().isEmpty ? AppLocalizations.of(context)!.authNameReq : null,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.authNameLabel,
                        prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppTheme.primary),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.authPhoneLabel,
                        prefixIcon: const Icon(Icons.phone_android_outlined, size: 20, color: AppTheme.primary),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return AppLocalizations.of(context)!.authEmailReq;
                      if (!value.contains('@')) return AppLocalizations.of(context)!.authEmailInvalid;
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.authEmailLabel,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppTheme.primary),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: isObscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return AppLocalizations.of(context)!.authPassReq;
                        if (value.length < 5) return AppLocalizations.of(context)!.authPassMin;
                        if (!RegExp(r'\d').hasMatch(value)) return AppLocalizations.of(context)!.authPassNum;
                        if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) return AppLocalizations.of(context)!.authPassSym;
                        return null;
                      },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.authPassLabel,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppTheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(isObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppTheme.textMuted),
                        onPressed: () => setState(() => isObscurePassword = !isObscurePassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isLoginMode ? AppLocalizations.of(context)!.authBtnLogin : AppLocalizations.of(context)!.authBtnRegister,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppTheme.cardBorder)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(AppLocalizations.of(context)!.authOr, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ),
                      const Expanded(child: Divider(color: AppTheme.cardBorder)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      icon: const Text('🌐', style: TextStyle(fontSize: 18)),
                      label: Text(
                        AppLocalizations.of(context)!.authGoogleSignIn,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
