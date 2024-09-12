import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
// import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart' as fp;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));
    ref.listen(
      authViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {
            // TODO: Navigate To HomePage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (_) => false,
            );
          },
          error: (error, st) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 130.0), // Add padding above the form
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign In.',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomField(
                        hintText: 'Email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      CustomField(
                        hintText: 'Password',
                        controller: passwordController,
                        isObscureText: true,
                      ),
                      const SizedBox(height: 15),
                      AuthGradientButton(
                        buttonText: "Sign In",
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .loginUser(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                          } else {
                            showSnackBar(context, 'Missing fields');
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ));
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.titleMedium,
                            children: const [
                              TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Pallete.gradient2,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
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
}
