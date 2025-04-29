import 'package:easycoutcol/config/api/login.dart';
import 'package:easycoutcol/config/api/RegisterUser.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  static const  String name='login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreen();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeySingin = GlobalKey<FormState>();
  String email='';
  String password='';  
  String name='';  
  String lastname='';  
  String username='';  
  String passwordConfirm='';  
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener((){
      // cambiar el state del tab
      setState(() {});
    });
  }
@override
Widget build(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return Scaffold(
    body: SafeArea(
      child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primary,
                    child: const Icon(Icons.add, size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EasyCountCol',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Unidades Formadoras de Colonias'),
                  const SizedBox(height: 24),
                  // TabBar con cambio de estado
                  TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}), // Importante para refrescar
                    tabs: const [
                      Tab(text: 'Iniciar Sesión'),
                      Tab(text: 'Crear Cuenta'),
                    ],
                  ),
                  const SizedBox(height: 16),
          
                  // Contenido con animación entre formularios
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _tabController.index == 0
                        ? _buildLoginForm()
                        : _buildSignUpPlaceholder(),
                  ),
                ],
              ),
            ),
          ),
    ),
  );
}


  Widget _buildLoginForm() {
    return Form(
      key: formKeyLogin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido de nuevo!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Ingresa tus credenciales para acceder a tu cuenta.'),
          const SizedBox(height: 24),
          InputCustom(
            labelInput: 'Correo electronico',hintInput: 'Ingrese su correo electronico',
            iconInput: const Icon(Icons.person),
            onChanged: (value){
              email=value;
              formKeyLogin.currentState?.validate();
            },
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<5) return 'El campo debe  tener una longitud valida.';
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',);
              if(!emailRegExp.hasMatch(value)) return 'El correo electronico no es valido.';
              return null;
            } ,
            keyboardType:TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          InputCustom(
              labelInput: 'Contraseña',hintInput: 'Ingrese la contraseña',
              iconInput: const Icon(Icons.password),
              obscureTextInput: _obscurePassword,
              onChanged: (value){
                password=value;
                formKeyLogin.currentState?.validate();
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value){
                if(value==null || value.isEmpty) return 'El campo es requerido.';
                if(value.length<5) return 'El campo debe  tener una longitud valida.';
                return null;
              } ,
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          CheckboxListTile(
            value: _rememberMe,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _rememberMe = value!;
              });
            },
            title: const Text('Recordar mi sesión'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
            Center(
              child: FilledButton.tonalIcon(
                    onPressed: () async {
                      // Verificar si esta validado o no
                      final isValid=formKeyLogin.currentState!.validate();
                      // Sino esta vlialoidadno no hacer nada
                      if(!isValid) return;
                      final resultado = await loginUsuario(
                        email: email,
                        password: password,
                      );
                      print('----------$resultado--------');
                      if (resultado['ok']) {
                      // Instancia del almacenamiento del usuario que inicio sesión
                      final sharedDatosUsuario = await SharedPreferences.getInstance();
                       // Almacenamiento del nombre de usuario
                      await sharedDatosUsuario.setString('name', resultado['name']);
                      await sharedDatosUsuario.setInt('id_usuario', resultado['id_user']);
                      // Mostrar modal de éxito y navegar
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Éxito'),
                          content: Text(resultado['message']),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Una vez que se registre solicitar iniciar sesión
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
                    icon: const Icon(Icons.arrow_forward), 
                    label:const Text('Entrar'),
                    style: FilledButton.styleFrom(    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),)),
            ),
        ],
      ),
    );
  }

  Widget _buildSignUpPlaceholder() {
  return Form(
      key: formKeySingin,
      child: Column(
        children: [
          const Text(
            'Bienvenido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Ingresa la información necesaria para registar  tu cuenta'),
          const SizedBox(height: 24),
          InputCustom(
            labelInput: 'Nombre',hintInput: 'Ingrese el nombre',
            iconInput: const Icon(Icons.person),
            onChanged: (value){
              name=value;
              formKeySingin.currentState?.validate();
            },
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<2) return 'El campo debe  tener una longitud valida.';
              return null;
            } ,
          ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Apellidos',hintInput: 'Ingrese los apellidos',
            iconInput: const Icon(Icons.account_circle),
            onChanged: (value){
              lastname=value;
              formKeySingin.currentState?.validate();
            },
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<5) return 'El campo debe  tener una longitud valida.';
              return null;
            } ,
          ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Nombre de usuario',hintInput: 'Ingrese el nombre de usuario',
            iconInput: const Icon(Icons.badge),
            onChanged: (value){
              username=value;
              formKeySingin.currentState?.validate();
            },
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<5) return 'El campo debe  tener una longitud valida.';
              return null;
            } ,
          ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Correo electronico', hintInput: 'Ingrese el correo electronico',
            onChanged: (value){
              email=value;
              formKeySingin.currentState?.validate();
            },
            keyboardType:TextInputType.emailAddress,
            iconInput: const Icon(Icons.email),
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',);
              if(!emailRegExp.hasMatch(value)) return 'El correo electronico no es valido.';

              return null;
            } 
            ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Contraseña', hintInput: 'Ingrese la contraseña',obscureTextInput: _obscurePassword,
            onChanged: (value){
              password=value;
              formKeySingin.currentState?.validate();
            },
            suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            iconInput: const Icon(Icons.password),
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<10) return 'El campo debe  adf una longitud valida.';
              return null;
            }
            ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Confirmar contraseña', hintInput: 'Confirme la contraseña ingresada',
            obscureTextInput: _obscurePasswordConfirm,
            onChanged: (value){
              passwordConfirm=value;
              formKeySingin.currentState?.validate();
            },
            suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePasswordConfirm = !_obscurePasswordConfirm;
                  });
                },
              ),
            iconInput: const Icon(Icons.password),
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              // Extrar el valor de la pantalla
              if (value != password) {
                return 'Las contraseñas no coinciden.';
              }
              return null;
            } 
            ),
          const SizedBox(height: 20,),
          FilledButton.tonalIcon(
            onPressed: () async {
            // Verificar si esta validado o no
            final isValid=formKeySingin.currentState!.validate();
            // Sino esta vlialoidadno no hacer nada
            if(!isValid) return;
            if (!context.mounted) return;
            final stateRegister = await sentUserRegister(
              name: name,
              lastname: lastname,
              username: username,
              email: email,
              password:password,
            );
            // Verificar que el wiget este montado
              if(stateRegister){
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                  title: const Text("Éxito"),
                  content: const Text("Usuario registrado correctamente."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Cerra ventana de dialogo
                        Navigator.pop(context);
                        // Cambiar el tab
                        _tabController.animateTo(0);
                        },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }else{
              showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      content: const Text('Ocurrio un error al registarse'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
            }
            },
            icon: const Icon(Icons.save), 
            label:const Text('Registarse' ),
            style: FilledButton.styleFrom(    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),)),
            const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
