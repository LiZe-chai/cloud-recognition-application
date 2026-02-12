import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../user_repository.dart';
import '../widgets/code_input_field.dart';

class verifyEmailPage extends StatefulWidget {
  final String emailAddress;
  const verifyEmailPage({super.key,required this.emailAddress});

  @override
  State<verifyEmailPage> createState() => _verifyEmailPageState();
}
class _verifyEmailPageState extends State<verifyEmailPage> {
  bool _isLoading = false;
  late String _enteredCode;
  String? codeError;

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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(S.of(context)!.checkEmail,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height:10),
                  Text(S.of(context)!.checkEmailInstruction(widget.emailAddress),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 30),
                  CodeInputField(
                    onChanged: (code) {
                      setState(() {
                        _enteredCode = code;
                      });
                      debugPrint("Completed code: $code");
                    },
                    onCompleted: (code) {
                      setState(() {
                        _enteredCode = code;
                      });
                      debugPrint("Completed code: $code");
                    },
                  ),
                  const SizedBox(height: 30),
                  codeError != null
                      ? Text(
                    codeError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() {
                        _isLoading = true;
                        codeError= null;
                      });
                      try {
                        await Future.delayed(const Duration(seconds: 2));
                        if (_enteredCode.length != 6) {
                          setState(() {
                            codeError = S.of(context)!.incompleteCode;
                          });
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Verify Successful")),
                        );
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
                      S.of(context)!.verifyCode,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context)!.haventReceiveCode),
                      InkWell(
                        onTap: () {
                          //resend code
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            S.of(context)!.resend,
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
      )
    );
  }
}