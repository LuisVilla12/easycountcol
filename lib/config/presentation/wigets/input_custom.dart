import 'package:flutter/material.dart';

class InputCustom extends StatelessWidget {
  final String? labelInput;
  final String? hintInput;
  final String? errorMessageInput;
  final Icon? iconInput;
  final bool obscureTextInput;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  const InputCustom({super.key, required this.labelInput, this.hintInput, this.errorMessageInput, this.onChanged, this.validator, this.obscureTextInput=false, this.iconInput  });


  @override
  Widget build(BuildContext context) {
    final colors=Theme.of(context).colorScheme;
    final borderCustom= OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      // borderSide: BorderSide(color: colors.primary)
    );
    return TextFormField(
      onChanged: onChanged,
      // Validar el campo
      validator: validator,
      obscureText: obscureTextInput,
      decoration: InputDecoration(
        // EStilo por default
        enabledBorder: borderCustom,
        // Cuando el usuario este dentro de ese campo
        focusedBorder: borderCustom.copyWith(borderSide: BorderSide(color: colors.primary)),
        errorBorder: borderCustom,
        focusedErrorBorder: borderCustom.copyWith(borderSide: BorderSide(color: Colors.red.shade700)),
        // Hacerlo mas delgado
        isDense: true,
        // Label
        label: labelInput!=null? Text(labelInput!):null,
        // Placeholder
        hintText: hintInput,
        // color cuando se le haga focus
        focusColor: colors.primary,
        errorText: errorMessageInput,
        // icon: Icon(Icons.account_box, color: colors.primary,)
        prefixIcon: iconInput
      ),
    );
  }
}