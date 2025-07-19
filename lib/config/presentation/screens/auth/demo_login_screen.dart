import 'package:easycoutcol/app/login.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String name = "login_screen";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormLogin(),
    );
  }
}

class FormLogin extends StatefulWidget {
  const FormLogin({
    super.key,
  });

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(
                  size: 210,
                ),
                const SizedBox(height: 25),
                InputCustom(
                  labelInput: 'Correo electronico',
                  hintInput: 'Ingrese su correo electronico',
                  iconInput: const Icon(Icons.person),
                  onChanged: (value) {
                    email = value;
                    formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'El campo es requerido.';
                    if (value.length < 5)
                      return 'El campo debe  tener una longitud valida.';
                    final emailRegExp = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegExp.hasMatch(value))
                      return 'El correo electronico no es valido.';
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InputCustom(
                  labelInput: 'Contraseña',
                  hintInput: 'Ingrese la contraseña',
                  iconInput: const Icon(Icons.password),
                  obscureTextInput: true,
                  onChanged: (value) {
                    password = value;
                    formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'El campo es requerido.';
                    if (value.length < 5)
                      return 'El campo debe  tener una longitud valida.';
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                FilledButton.tonalIcon(
                    onPressed: () async {
                      // Verificar si esta validado o no
                      final isValid = formKey.currentState!.validate();
                      // Sino esta vlialoidadno no hacer nada
                      if (!isValid) return;
                      final resultado = await loginUsuario(
                        email: email,
                        password: password,
                      );
                      if (resultado['ok']) {
                        // Mostrar modal de éxito y navegar
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Éxito'),
                            content: Text(resultado['message']),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.pushNamed(HomeScreen.name);
                                },
                                child: const Text('Continuar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Mostrar modal de error
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(resultado['message']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: Text('Acceder', style: titleStyle),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
