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
    // Lista de colores
    // final List<Color>colors=ref.watch(colorListProvider);
    final List<Map<String, dynamic>> colors = ref.watch(colorListProvider);
    final  selectedColor=ref.watch(selectedColorProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
            children: [
              // Vista previa del tema
              Container(
                decoration: BoxDecoration(
                  color: colors[selectedColor]['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.palette, size: 48, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Vista previa del tema seleccionado",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: List.generate(3, (i) {
                    //     final index = (selectedColor + i) % colors.length;
                    //     return Container(
                    //       margin: const EdgeInsets.symmetric(horizontal: 4),
                    //       width: 20,
                    //       height: 20,
                    //       decoration: BoxDecoration(
                    //         color: colors[index]['color'],
                    //         shape: BoxShape.circle,
                    //       ),
                    //     );
                    //   }),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
      
              // Lista de opciones de color
              Expanded(
                child: ListView.builder(
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final isSelected = index == selectedColor;
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedColorProvider.notifier).state = index;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? color['color'] : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            color['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '#${color['color'].value.toRadixString(16).padLeft(8, '0')}',
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: color['color'])
                              : Icon(Icons.radio_button_unchecked),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
    );
  //   return ListView.builder(
  //     itemCount: colors.length,
  //     itemBuilder: (contex, index){
  //     final Color color=colors[index];
  //     return RadioListTile(
  //       title:Text('Este color', style: TextStyle(color: color),),
  //       subtitle: Text('${color.value}'),
  //       activeColor: color,
  //       value: index, 
  //       groupValue:selectedColor , 
  //       onChanged: (value){
  //       // Notificar el cambio
  //       ref.read(selectedColorProvider.notifier).state=index;
  //     }) ;
  //   });
  }
}