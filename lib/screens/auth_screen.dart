// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smart_study_planner/state/app_state.dart';
// import 'package:smart_study_planner/theme/app_colors.dart';
// import 'package:smart_study_planner/widgets/animated_scale_button.dart';
// import 'package:smart_study_planner/routes/app_routes.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   bool _isLoginMode = true;
//   bool _isLoading = false;

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   void _openForgotPasswordScreen() {
//     Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _submitAuth() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);
//     final appState = context.read<AppState>();

//     // NEW: Variable to hold the message from AppState
//     String? errorMessage;

//     // 1. Send the data to Firebase and wait for the String response
//     if (_isLoginMode) {
//       errorMessage = await appState.login(
//         _emailController.text,
//         _passwordController.text,
//       );
//     } else {
//       if (_nameController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter your Full Name')),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }
//       errorMessage = await appState.signUp(
//         _emailController.text,
//         _passwordController.text,
//         _nameController.text,
//       );
//     }

//     if (!mounted) return;
//     setState(() => _isLoading = false); // Stop the loading spinner

//     // 2. THE GATEKEEPER: Did Firebase return an error?
//     if (errorMessage != null) {
//       // ❌ FAILED: Show the error banner and STOP. Do NOT navigate!
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red.shade400,
//         ),
//       );
//     } else {
//       // ✅ SUCCESS: errorMessage is null, so we are safe to enter the app!
//       Navigator.of(
//         context,
//       ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(30),
//                     decoration: BoxDecoration(
//                       color: AppColors.secondaryYellow.withValues(alpha: 0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.school_rounded,
//                       size: 100,
//                       color: AppColors.primaryOlive,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 Text(
//                   _isLoginMode ? 'Welcome Back!' : 'Create Account',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.deepBrown,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _isLoginMode
//                       ? 'Log in to access your study planner'
//                       : 'Sign up to start organizing your studies',
//                   style: TextStyle(
//                     color: AppColors.deepBrown.withValues(alpha: 0.6),
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 if (!_isLoginMode) ...[
//                   _buildTextField(
//                     controller: _nameController,
//                     label: 'Full Name',
//                     icon: Icons.person_outline_rounded,
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 _buildTextField(
//                   controller: _emailController,
//                   label: 'Email Address',
//                   icon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 16),

//                 _buildTextField(
//                   controller: _passwordController,
//                   label: 'Password (min 6 chars)',
//                   icon: Icons.lock_outline_rounded,
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   child: AnimatedScaleButton(
//                     onTap: _isLoading ? () {} : _submitAuth,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       decoration: BoxDecoration(
//                         color: _isLoading
//                             ? Colors.grey
//                             : AppColors.primaryOlive,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.primaryOlive.withValues(
//                               alpha: 0.3,
//                             ),
//                             blurRadius: 12,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       alignment: Alignment.center,
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 24,
//                               width: 24,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 3,
//                               ),
//                             )
//                           : Text(
//                               _isLoginMode ? 'Log In' : 'Sign Up',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontSize: 18,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),

//                 if (_isLoginMode)
//                   Center(
//                     child: TextButton(
//                       onPressed: _openForgotPasswordScreen,
//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           color: AppColors.accentOrange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 24),

//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _isLoginMode = !_isLoginMode;
//                       });
//                     },
//                     child: RichText(
//                       text: TextSpan(
//                         text: _isLoginMode
//                             ? "Don't have an account? "
//                             : "Already have an account? ",
//                         style: TextStyle(
//                           color: AppColors.deepBrown.withValues(alpha: 0.7),
//                           fontSize: 15,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: _isLoginMode ? 'Sign Up' : 'Log In',
//                             style: const TextStyle(
//                               color: AppColors.accentOrange,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType? keyboardType,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: AppColors.primaryOlive),
//         prefixIcon: Icon(icon, color: AppColors.primaryOlive),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: const BorderSide(color: AppColors.primaryOlive, width: 2),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/routes/app_routes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _isLoading = false;
  bool _passwordVisible = false; // NEW: Toggle state for password visibility

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _openForgotPasswordScreen() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = context.read<AppState>();

    String? errorMessage;

    if (_isLoginMode) {
      errorMessage = await appState.login(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your Full Name')),
        );
        setState(() => _isLoading = false);
        return;
      }
      errorMessage = await appState.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 100,
                      color: AppColors.primaryOlive,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  _isLoginMode ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode
                      ? 'Log in to access your study planner'
                      : 'Sign up to start organizing your studies',
                  style: TextStyle(
                    color: AppColors.deepBrown.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                if (!_isLoginMode) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password (min 6 chars)',
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_passwordVisible, // Dynamic based on eye icon
                  isPasswordField: true, // Pass true to enable the eye icon
                ),

                // NEW: Repositioned Forgot Password button immediately after password field
                if (_isLoginMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openForgotPasswordScreen,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: AnimatedScaleButton(
                    onTap: _isLoading ? () {} : _submitAuth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? Colors.grey
                            : AppColors.primaryOlive,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOlive.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isLoginMode ? 'Log In' : 'Sign Up',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: _isLoginMode
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(
                          color: AppColors.deepBrown.withValues(alpha: 0.7),
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: _isLoginMode ? 'Sign Up' : 'Log In',
                            style: const TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPasswordField = false, // New parameter to handle password toggle
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryOlive),
        prefixIcon: Icon(icon, color: AppColors.primaryOlive),
        // NEW: Add the eye toggle icon for the password field
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primaryOlive, width: 2),
        ),
      ),
    );
  }
}
