import 'dart:async' show TimeoutException;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart';

typedef OnLoginSuccess = void Function();

class LoginScreen extends StatefulWidget {
  final OnLoginSuccess onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginStage {
  splash,
  login,
  forgotPassword,
  resetCode,
  setNewPassword,
}

class _LoginScreenState extends State<LoginScreen> {
  LoginStage _stage = LoginStage.splash;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _resetCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStage(LoginStage stage) {
    setState(() {
      _stage = stage;
      if (stage == LoginStage.login) {
        _passwordController.clear();
      } else if (stage == LoginStage.forgotPassword) {
        _forgotEmailController.clear();
      } else if (stage == LoginStage.resetCode) {
        _resetCodeController.clear();
      } else if (stage == LoginStage.setNewPassword) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  Future<void> _performLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7/auth_api/login.php'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      
      debugPrint('Full API Response: ${response.body}');

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          _showMessage('Welcome ${responseData['user']['name']}!');
          widget.onLoginSuccess();
        } else {
          final errorMsg = responseData['message'] ?? 'Login failed';
          final details = responseData['error'] ?? responseData['details'] ?? 'No details provided';
          _showMessage('$errorMsg\n$details');
        }
      } else {
        final errorMsg = responseData['message'] ?? 'Server error';
        final details = responseData['error'] ?? responseData['details'] ?? 'Status code: ${response.statusCode}';
        _showMessage('$errorMsg\n$details');
        debugPrint('Error Details: $details');
      }
    } on SocketException {
      _showMessage('Network error: Cannot connect to server');
    } on TimeoutException {
      _showMessage('Connection timeout: Server took too long to respond');
    } on FormatException {
      _showMessage('Invalid server response format');
    } catch (e) {
      _showMessage('Unexpected error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sendResetPasswordEmail() {
    final email = _forgotEmailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }
    _goToStage(LoginStage.resetCode);
  }

  void _verifyResetCode() {
    final code = _resetCodeController.text.trim();
    if (code.length != 6) {
      _showMessage('Please enter the 6-digit code');
      return;
    }
    _goToStage(LoginStage.setNewPassword);
  }

  void _resetPassword() {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage('Please enter all password fields');
      return;
    }
    if (newPass != confirmPass) {
      _showMessage('Passwords do not match');
      return;
    }
    if (newPass.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }

    _showMessage('Password reset successful. Please log in.');
    _goToStage(LoginStage.login);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _buildSplash() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EBEC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/IMAGENETION.png',
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'IMAGENETION',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: screenHeight * 0.15),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: ElevatedButton(
                    onPressed: () => _goToStage(LoginStage.login),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: const Color(0xFF11D6DA),
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: Text(
                      'START',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EBEC),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFD3EBEC),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => _goToStage(LoginStage.splash),
            child: Text('Back', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: Container(
                    width: screenWidth * 0.85,
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/IMAGENETION.png',
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.04,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.04,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: IconButton(
                              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _goToStage(LoginStage.forgotPassword),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _performLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, screenHeight * 0.06),
                            backgroundColor: const Color(0xFF11D6DA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                  onRegisterSuccess: () {
                                    Navigator.pop(context);
                                    _showMessage('Registration successful. Please log in.');
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Don't have an account? Register",
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForgotPassword() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EBEC),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xFFD3EBEC),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => _goToStage(LoginStage.login),
            child: Text('Back', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Center(
            child: Container(
              width: screenWidth * 0.85,
              margin: EdgeInsets.only(
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.1,
              ),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the email address associated with your account.',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextField(
                    controller: _forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: _sendResetPasswordEmail,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      backgroundColor: const Color(0xFF11D6DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetCode() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EBEC),
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color(0xFFD3EBEC),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => _goToStage(LoginStage.forgotPassword),
            child: Text('Back', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Center(
            child: Container(
              width: screenWidth * 0.85,
              margin: EdgeInsets.only(
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.1,
              ),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the 6-digit code sent to your email.',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextField(
                    controller: _resetCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04,
                      ),
                      prefixIcon: const Icon(Icons.message_outlined),
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: _verifyResetCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      backgroundColor: const Color(0xFF11D6DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetNewPassword() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EBEC),
      appBar: AppBar(
        title: const Text('Set New Password'),
        backgroundColor: const Color(0xFFD3EBEC),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: () => _goToStage(LoginStage.resetCode),
            child: Text('Back', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Center(
            child: Container(
              width: screenWidth * 0.85,
              margin: EdgeInsets.only(
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.1,
              ),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_newPasswordVisible,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(_newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      backgroundColor: const Color(0xFF11D6DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case LoginStage.splash:
        return _buildSplash();
      case LoginStage.login:
        return _buildLogin();
      case LoginStage.forgotPassword:
        return _buildForgotPassword();
      case LoginStage.resetCode:
        return _buildResetCode();
      case LoginStage.setNewPassword:
        return _buildSetNewPassword();
      default:
        return _buildSplash();
    }
  }
}