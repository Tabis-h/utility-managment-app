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
  final TextEditingController workPriceController = TextEditingController(); // For work price
  String selectedRole = "";
  String selectedWorkType = ""; // For work type dropdown
  bool isLoading = false;

  // List of work types for the dropdown
  final List<String> workTypes = [
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
    "Mechanic",
  ];

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    workPriceController.dispose();
  }

  void signupUser() async {
    if (selectedRole.isEmpty) {
      showSnackBar(context, "Please select a role (User or Worker)");
      return;
    }

    if (selectedRole == "Worker") {
      if (workPriceController.text.isEmpty || selectedWorkType.isEmpty) {
        showSnackBar(context, "Please fill all worker-specific fields");
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      role: selectedRole,
    );

    if (res == "success") {
      setState(() {
        isLoading = false;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;

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
                              selectedWorkType = ""; // Reset worker fields
                              workPriceController.clear();
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

              // Additional fields for Worker role
              if (selectedRole == "Worker") ...[
                TextFieldInput(
                  icon: Icons.attach_money,
                  textEditingController: workPriceController,
                  hintText: 'Enter your work price',
                  textInputType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedWorkType.isNotEmpty ? selectedWorkType : null,
                    items: workTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkType = value ?? "";
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Work Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],

              MyButtons(onTap: signupUser, text: isLoading ? "Signing Up..." : "Sign Up"),
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
