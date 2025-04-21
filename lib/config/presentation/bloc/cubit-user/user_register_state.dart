part of 'user_register_cubit.dart';

// Estados del formulario
enum FormStatus{invalid, valid, validating, posting}

class UserRegisterState extends Equatable {
  final FormStatus formStatus;
  final String name;
  final String lastname;
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  final bool passwordsMatch;


  const UserRegisterState({
    this.formStatus=FormStatus.invalid, this.username='', this.email='', this.password='',this.passwordConfirm='', this.passwordsMatch=true, this.name='',this.lastname=''});

UserRegisterState copyWith({
    // Opcionales porque no sabe que cambio
    FormStatus? formStatus,
    String? name,
    String? lastname,
    String? username,
    String? email,
    String? password,
    String? passwordConfirm,
    bool? passwordsMatch,
  })=>UserRegisterState(
    formStatus: formStatus??this.formStatus,
    name: name??this.name,
    lastname: lastname??this.lastname,
    username: username??this.username,
    email: email??this.email,
    password: password??this.password,
    passwordConfirm: password??this.passwordConfirm,
    passwordsMatch: passwordsMatch??this.passwordsMatch,
  );


  @override
  List<Object> get props => [formStatus,name,lastname,username,email,password,passwordConfirm,passwordsMatch];
}



