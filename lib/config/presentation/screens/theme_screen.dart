import 'package:easycoutcol/config/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeScreen extends ConsumerWidget {
  static const String name='theme_name';
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context,ref) {
    final bool isDarkmode=ref.watch(isDarkModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar tema'),
        actions: [
          IconButton(onPressed: (){
            // Actualizar el valor del provider
            ref.read(isDarkModeProvider.notifier).update((state) => !state);
          }, icon:Icon( isDarkmode? Icons.dark_mode_outlined : Icons.light_mode_outlined)),
        ],
        ),
        body: const _ThemeChangerScreen(),
    );
  }
}

class _ThemeChangerScreen extends ConsumerWidget {
  const _ThemeChangerScreen();

  @override
  Widget build(BuildContext context,ref) {

    final List<Color>colors=ref.watch(colorListProvider);
    final int selectedColor=ref.watch(selectedColorProvider);
    
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (contex, index){
      final Color color=colors[index];
      return RadioListTile(
        title:Text('Este color', style: TextStyle(color: color),),
        subtitle: Text('${color.value}'),
        activeColor: color,
        value: index, 
        groupValue:selectedColor , 
        onChanged: (value){
        // Notificar el cambio
        ref.read(selectedColorProvider.notifier).state=index;
      }) ;
    });
  }
}