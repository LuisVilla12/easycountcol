import 'package:easycoutcol/config/api/registerUser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


part 'user_register_state.dart';

class UserRegisterCubit extends Cubit<UserRegisterState> {
  UserRegisterCubit() : super(const UserRegisterState());
  
  Future<bool> onSubmitForm() async{
    final state = this.state;
    final stateRegister = await sentUserRegister(
      name: state.name,
      lastname: state.lastname,
      username: state.username,
      email: state.email,
      password: state.password,
    );
  return stateRegister;
  }
  void nameChanged(String vale){
    emit(state.copyWith(name: vale));
  }
  void lastnameChanged(String vale){
    emit(state.copyWith(lastname: vale));
  }
  void usernameChanged(String vale){
    emit(state.copyWith(username: vale));
  }
  void emailChanged(String vale){
    emit(state.copyWith(email: vale));
  }
  void passwordChanged(String vale){
    emit(state.copyWith(password: vale,passwordsMatch: vale == state.passwordConfirm));
  }
  void passwordConfirmChanged(String vale){
    emit(state.copyWith(passwordConfirm: vale,passwordsMatch: vale == state.passwordConfirm));
  }
}


