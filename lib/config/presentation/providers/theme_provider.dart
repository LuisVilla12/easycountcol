// Estado del darkmode
import 'package:easycoutcol/config/theme/app_theme.dart';
import 'package:riverpod/riverpod.dart';
// definir el provider del modo dark
final isDarkModeProvider=StateProvider((ref)=>false);
// Listado de colores
final colorListProvider=Provider((ref)=>colorList);
// Saber el color seleccionado
final selectedColorProvider=StateProvider((ref)=>3);