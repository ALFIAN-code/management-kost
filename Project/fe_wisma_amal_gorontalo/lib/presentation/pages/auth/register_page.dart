import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, this.pendingRoom});

  final RoomEntity? pendingRoom;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Toggle obscure text on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const ToggleObscureTextEvent());
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppbar(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        title: 'Back',
      ),
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade300,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
              child: Row(
                children: [
                  // Text(
                  //   'Wisma Amal',
                  //   style: StyleConstant.customTextStyle.copyWith(
                  //     fontSize: 25,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                // height: 700,
                // width: 600,
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) async {
                    if (state.status.isFailure) {
                      AppSnackbar.showError(
                        state.errorMessage ?? 'Register failed',
                      );
                    }
                    if (state.isLoggedIn && state.errorMessage == null) {
                      if (pendingRoom != null) {
                        await context.router.replaceAll([
                          AppLayoutRoute(
                            children: [
                              ReservationDetailFormRoute(room: pendingRoom!),
                            ],
                          ),
                        ]);
                      } else {
                        await context.router.replaceAll([
                          const AppLayoutRoute(
                            children: [RoomRoute()],
                          ),
                        ]);
                      }
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Register Page',
                              style: StyleConstant.customTextStyle.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Create a new account to continue',
                              style: StyleConstant.customTextStyle.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextForm(
                                    controller: usernameController,
                                    title: 'Username',
                                    hintText: 'John Doe',
                                    isRequired: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Username is required';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: CustomTextForm(
                                    controller: emailController,
                                    title: 'Email',
                                    hintText: 'johnDoe@mail.com',
                                    isRequired: true,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(
                                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Invalid email format';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                            CustomTextForm(
                              controller: passwordController,
                              title: 'Password',
                              hintText: '***********',
                              isRequired: true,
                              obscureText: state.obscureText,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    const ToggleObscureTextEvent(),
                                  );
                                },
                                icon: Icon(
                                  !state.obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            CustomTextForm(
                              controller: passwordConfirmController,
                              title: 'Confirm Password',
                              hintText: '***********',
                              isRequired: true,
                              obscureText: state.obscureText,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    const ToggleObscureTextEvent(),
                                  );
                                },
                                icon: Icon(
                                  !state.obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30),
                            BasicButton(
                              onPressed: state.status.isInProgress
                                  ? null
                                  : () async {
                                      // Run the validator
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        // If valid, dispatch the register event
                                        context.read<AuthBloc>().add(
                                          RegisterEvent(
                                            username: usernameController.text,
                                            email: emailController.text,
                                            password: passwordController.text,
                                            passwordConfirm:
                                                passwordConfirmController.text,
                                          ),
                                        );
                                      } else {
                                        // If not valid, show the error snackbar
                                        AppSnackbar.showError(
                                          'Please review the data you entered',
                                        );
                                      }
                                    },
                              label: state.status.isInProgress
                                  ? 'Loading...'
                                  : 'Register',
                            ),
                            SizedBox(height: 30),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: StyleConstant.customTextStyle.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.router.navigate(
                                      LoginRoute(pendingRoom: pendingRoom),
                                    );
                                  },
                                  child: Text('Login here'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
