import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../user_repository.dart';
import 'verifyEmail.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final UserRepository _userRepo = UserRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _emailError;
  bool _passwordError = false;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,size:50),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
     ),
      body: SafeArea(
          child: Padding(
            padding:  const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      S.of(context)!.signUp,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(S.of(context)!.email,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                  const SizedBox(height: 50),
                  Text(S.of(context)!.password,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, size: 12, color: _passwordError ? Colors.red : Colors.grey[800]),
                      SizedBox(width: 4),
                      Expanded( //
                        child: Text(
                          S.of(context)!.passwordRegex,
                          style: TextStyle(fontSize: 12, color: _passwordError ? Colors.red : Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(S.of(context)!.confirmPassword,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: S.of(context)!.confirmPasswordInstruction,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      errorText: _confirmPasswordError,
                      errorMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 70),

                  // Continue button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      String confirmPassword = _confirmPasswordController.text.trim();

                      setState(() {
                        _isLoading = true;
                        _emailError = null;
                        _passwordError = false;
                        _confirmPasswordError = null;
                      });
                      try {
                        final userExist = await _userRepo.mockUserExists(email);
                        if (!userExist){
                          final passworValid = await _userRepo.isPasswordValid(password);
                          if(passworValid){
                            if(password == confirmPassword){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("✅ Create account successful!")),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => verifyEmailPage(emailAddress: email)),
                              );
                            }else{
                              setState(() {
                                _confirmPasswordError = S.of(context)!.passwordNotMatch;
                              });
                            }
                          }else{
                            setState(() {
                              _passwordError = true;
                            });
                          }
                        }else{
                          setState(() {
                            _emailError = S.of(context)!.emailExist;
                          });
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
                      S.of(context)!.signUp,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
  
}
