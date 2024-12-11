import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utiliwise/worker/worker_dashboard.dart';

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

  void signupUser() async {
    if (selectedRole.isEmpty) {
      showSnackBar(context, "Please select a role (User or Worker)");
      return;
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
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          if (selectedRole == "Worker") {
            if (workPriceController.text.isEmpty) {
              showSnackBar(context, "Please enter your work price");
              setState(() {
                isLoading = false;
              });
              return;
            }
            if (selectedWorkType.isEmpty) {
              showSnackBar(context, "Please select your work type");
              setState(() {
                isLoading = false;
              });
              return;
            }
            await firestore.collection('workers').doc(user.uid).set({
              'name': nameController.text,
              'email': emailController.text,
              'role': 'Worker',
              'uid': user.uid,
              'workPrice': workPriceController.text,
              'workType': selectedWorkType,
              'kyc': {
                'status': 'not_submitted',
                'documentType': '',
                'documentUrl': '',
                'selfieUrl': '',
              }
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
            builder: (context) => selectedRole == "Worker"
                ? const WorkerDashboard()
                : HomeView(userType: selectedRole.toLowerCase()),
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

  Widget _buildRoleToggle(String role, IconData icon) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: role == "User" ? Radius.circular(25) : Radius.zero,
            right: role == "Worker" ? Radius.circular(25) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 8),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Select Your Role",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRoleToggle("User", Icons.person),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.grey.shade300,
                      ),
                      _buildRoleToggle("Worker", Icons.work),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                    items: [
                      'Plumber',
                      'Electrician',
                      'Carpenter',
                      'Painter',
                      'Mechanic',
                      'Gardener',
                    ]
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
                const SizedBox(height: 20),
                MyButtons(
                  onTap: signupUser,
                  text: isLoading ? "Signing Up..." : "Sign Up",
                ),
                const SizedBox(height: 10),
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
      ),
    );
  }
}
