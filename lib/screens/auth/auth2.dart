// import 'dart:math';

// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth2 extends StatefulWidget {
  const Auth2({Key? key, required this.signup}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final signup;
  @override
  State<Auth2> createState() => _Auth2State();
}

class _Auth2State extends State<Auth2> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SharedPreferences? prefs;

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: widget.signup ? const Text('Sign up') : const Text('Sign in'),
          leading: TextButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Welcome to PDF Made Easy',
                      style: TextStyle(fontSize: 20)),
                  const Gap(4),
                  if (widget.signup) const Text('Please sign up to continue'),
                  const Gap(10),
                  if (!widget.signup) const Text('Please sign in to continue'),
                  const Gap(10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                  if (!widget.signup)
                    ElevatedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // Navigator.pushNamed(context, '/auth');
                        try {
                          var email = emailController.text;
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: passwordController.text,
                          );
                          // print(emailController.text);
                          // print(email.toString());
                          await prefs?.setString('email', email.toString());
                          prefs?.setString('email', emailController.text);
                          // print(prefs?.getString('email'));
                          Navigator.of(context).pop();
                          // print(prefs);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                      child: const Text('Sign in'),
                    ),
                  const Gap(4),
                  if (widget.signup)
                    ElevatedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // Navigator.pushNamed(context, '/auth');
                        try {
                          var email = emailController.text;
                          var pass = passwordController.text;
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: pass,
                          );
                          Future.delayed(const Duration(seconds: 1), () async {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: email,
                              password: pass,
                            );
                          });
                          prefs?.setString('email', emailController.text);
                          Navigator.of(context).pop();
                        } catch (e) {
                          // print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                        prefs?.setString('email', emailController.text);
                        // FirebaseAuth.instance.signInWithEmailAndPassword(
                        //   email: emailController.text,
                        //   password: passwordController.text,
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'User created and signed in successfully!'),
                          ),
                        );
                      },
                      child: const Text('Sign up'),
                    ),
                ],
              ),
            ),
            //   ),
          ),
        ),
      ),
    );
  }
}
