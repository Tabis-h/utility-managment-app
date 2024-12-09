import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController workPriceController = TextEditingController();
  String selectedRole = ""; // Holds the selected role
  String selectedWorkType = ""; // Holds the selected work type
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    workPriceController.dispose();
  }

  // Updated signupUser method with Firestore logic
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
      role: selectedRole,
    );

    // Handle the response
    if (res == "success") {
      setState(() {
        isLoading = false;
      });

      // After successful sign-up, store the user in the appropriate Firestore collection
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Store data based on role
          if (selectedRole == "Worker") {
            await firestore.collection('workers').doc(user.uid).set({
              'name': nameController.text,
              'email': emailController.text,
              'role': 'Worker',
              'uid': user.uid,
              'workPrice': workPriceController.text,
              'workType': selectedWorkType,
            });
          } else {
            await firestore.collection('users').doc(user.uid).set({
              'name': nameController.text,
              'email': emailController.text,
              'role': 'User',
              'uid': user.uid,
            });
          }
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeView(),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, e.toString());
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                textInputType: TextInputType.emailAddress,
              ),
              TextFieldInput(
                icon: Icons.lock,
                textEditingController: passwordController,
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
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
                    if (selectedRole == "Worker") ...[
                      const SizedBox(height: 10),
                      TextFieldInput(
                        icon: Icons.monetization_on,
                        textEditingController: workPriceController,
                        hintText: 'Enter work price',
                        textInputType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWorkType.isEmpty ? null : selectedWorkType,
                        items: ['Plumber', 'Electrician', 'Carpenter']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWorkType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Work Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              MyButtons(
                onTap: signupUser,
                text: isLoading ? "Signing Up..." : "Sign Up",
              ),
              const SizedBox(height: 50),
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
