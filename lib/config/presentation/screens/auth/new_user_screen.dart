import 'package:easycoutcol/config/presentation/bloc/cubit-user/user_register_cubit.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
class NewUserScreen extends StatelessWidget {
  static const String name='new_user_screen';
  const NewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => UserRegisterCubit(),
        child: ViewFormRegisterUser(),
      ),
    );
  }
}

class ViewFormRegisterUser extends StatelessWidget {
  const ViewFormRegisterUser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(size: 200,),
              FormRegisterUser()
            ],
          ),
        ),),
    );
  }
}

class FormRegisterUser extends StatefulWidget {

  const FormRegisterUser({
    super.key,
  });

  @override
  State<FormRegisterUser> createState() => _FormRegisterUserState();
}

class _FormRegisterUserState extends State<FormRegisterUser> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final registerCubit= context.watch<UserRegisterCubit>();
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 40,),
          InputCustom(
            labelInput: 'Nombre',hintInput: 'Ingrese el nombre',
            iconInput: const Icon(Icons.person),
            onChanged: (value){
              registerCubit.nameChanged(value);
              formKey.currentState?.validate();
            },
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              if(value.length<5) return 'El campo debe  tener una longitud valida.';
              return null;
            } ,
          ),
          const SizedBox(height: 20,),
          InputCustom(
            labelInput: 'Apellidos',hintInput: 'Ingrese los apellidos',
            iconInput: const Icon(Icons.person),
            onChanged: (value){
              registerCubit.lastnameChanged(value);
              formKey.currentState?.validate();
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
            iconInput: const Icon(Icons.person),
            onChanged: (value){
              registerCubit.usernameChanged(value);
              formKey.currentState?.validate();
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
              registerCubit.emailChanged(value);
              formKey.currentState?.validate();
            },
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
            labelInput: 'Contraseña', hintInput: 'Ingrese la contraseña',obscureTextInput: true,
            onChanged: (value){
              registerCubit.passwordChanged(value);
              formKey.currentState?.validate();
            },
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
            obscureTextInput: true,
            onChanged: (value){
              registerCubit.passwordConfirmChanged(value);
              formKey.currentState?.validate();
            },
            iconInput: const Icon(Icons.password),
            validator: (value){
              if(value==null || value.isEmpty) return 'El campo es requerido.';
              // Extrar el valor de la pantalla
              final password = registerCubit.state.password;
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
            final isValid=formKey.currentState!.validate();
            // Sino esta vlialoidadno no hacer nada
            if(!isValid) return;
            final stateRegister=await registerCubit.onSubmitForm();
            if (!context.mounted) return;
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
                        Navigator.pop(context);
                        context.pushNamed(HomeScreen.name);
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
            label:Text('Registarse' , style:titleStyle,),
            style: FilledButton.styleFrom(    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),)),
            const SizedBox(height: 20,),

        ],
      ),
    );
  }
}