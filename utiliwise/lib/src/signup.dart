import 'package:flutter/material.dart';

import '../Services/authentication.dart';
import '../Widget/button.dart';
import '../Widget/snackbar.dart';

import '../Widget/text_field.dart';
import 'home.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = ""; // Holds the selected role
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signupUser() async {
    if (selectedRole.isEmpty) {
      // Show an error if no role is selected
      showSnackBar(context, "Please select a role (User or Worker)");
      return;
    }

    // Set isLoading to true
    setState(() {
      isLoading = true;
    });

    // Signup user using AuthMethod
    String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      role: selectedRole, // Pass the selected role
    );

    // Handle the response
    if (res == "success") {
      setState(() {
        isLoading = false;
      });

      // Navigate to the next screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeView(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });

      // Show error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.8,
                child: Image.asset('images/signup.jpeg'),
              ),
              TextFieldInput(
                icon: Icons.person,
                textEditingController: nameController,
                hintText: 'Enter your name',
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                icon: Icons.email,
                textEditingController: emailController,
                hintText: 'Enter your email',
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                icon: Icons.lock,
                textEditingController: passwordController,
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                isPass: true,
              ),

              // Role Selection Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Text(
                      "Select Your Role",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedRole = "User";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedRole == "User"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text("User"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedRole = "Worker";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedRole == "Worker"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text("Worker"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Signup Button
              MyButtons(onTap: signupUser, text: isLoading ? "Signing Up..." : "Sign Up"),

              const SizedBox(height: 50),

              // Login Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      " Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
