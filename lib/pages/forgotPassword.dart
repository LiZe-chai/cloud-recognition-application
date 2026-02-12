import 'package:cloud_recognition/pages/resetPassword.dart';
import 'package:cloud_recognition/pages/verifyEmail.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../user_repository.dart';

class forgotPasswordPage extends StatefulWidget {
  const forgotPasswordPage({super.key});

  @override
  State<forgotPasswordPage> createState() => _forgotPasswordPageState();
}
class _forgotPasswordPageState extends State<forgotPasswordPage> {
  final UserRepository _userRepo = UserRepository();
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
          padding:  const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(S.of(context)!.forgotPasswordT, style:
                TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(S.of(context)!.emailInstructionFP, style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color: Colors.grey[800])),
                const SizedBox(height: 30),
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
                const SizedBox(height: 70),

                // Continue button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    String email = _emailController.text.trim();

                    setState(() {
                      _isLoading = true;
                      _emailError = null;
                    });
                    try {
                      final userExist = await _userRepo.isUserExist(email);
                      if (userExist){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => verifyEmailPage(emailAddress: email, mode: 'reset password',)),
                        );
                      }else{
                        setState(() {
                          _emailError = S.of(context)!.emailNExist;
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
                    S.of(context)!.verifyEmail,
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