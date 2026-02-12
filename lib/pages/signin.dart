import 'package:cloud_recognition/pages/signup.dart';
import 'package:cloud_recognition/pages/forgotPassword.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../user_repository.dart';
import '../generated/l10n.dart';


class SignInPage extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const SignInPage({super.key,this.setLocale});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final UserRepository _userRepo = UserRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:"248671681961-btohhh0mk2qkdco18614q3gllgjuvdvn.apps.googleusercontent.com"
  );

  String? _jwt;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isLoading = false; //waiting api call

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _jwt = null;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    await _googleSignIn.signOut();
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken != null) {
        final jwt = await _userRepo.loginWithGoogle(idToken);
        setState(() {
          _jwt = jwt;
        });
        debugPrint("✅ Login successful，JWT: $_jwt");
        if (jwt != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInPage()),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Google login failed: $e");
      await _googleSignIn.signOut();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.black),
            onSelected: (Locale locale) {
              widget.setLocale?.call(locale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              PopupMenuItem(
                value: Locale('zh'),
                child: Text('中文'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // Email
                Text(S.of(context)!.email,
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: S.of(context)!.emailInstruction,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                Text(S.of(context)!.password,
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: S.of(context)!.passwordInstruction,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorText: _passwordError,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => forgotPasswordPage()),
                      );
                    },
                    child: Text(S.of(context)!.forgotPassword,
                        style: TextStyle(color: Colors.blue)),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    setState(() {
                      _isLoading = true;
                      _emailError = null;
                      _passwordError = null;
                    });
                    await Future.delayed(const Duration(seconds: 2));
                    try {
                      final response = await _userRepo.requestLogin(email, password);

                      if (response == "User not found") {
                        setState(() {
                          _emailError = S.of(context)!.emailError;
                        });
                      } else if (response == "Wrong password") {
                        setState(() {
                          _passwordError = S.of(context)!.passwordError;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Login successful!")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("⚠️ Error: $e")),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false; // finish loading
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4CE0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    S.of(context)!.login,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with OR
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 40),


                // Login with Google
                OutlinedButton.icon(
                  onPressed: () {
                    _handleGoogleSignIn();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset("assets/google.png", height: 20), // Google logo
                  label: Text(S.of(context)!.loginWithGoogle,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: 24),

                // Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(S.of(context)!.dontHaveAnAccount),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );

                      },
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          S.of(context)!.signUpNow,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
