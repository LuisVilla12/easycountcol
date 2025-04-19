import 'package:easycoutcol/config/menu/menu_items.dart';
import 'package:easycoutcol/config/presentation/screens/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class SideMenu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // Saber que opción selecciono
  int navDrawerIndex=0;
  @override
  Widget build(BuildContext context) {
    // Saber el padding top
    final hasNotch=MediaQuery.of(context).viewPadding.top>25;
    final titleStyle=Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  );

    return NavigationDrawer(
      // Saber que opcion selecciono
      selectedIndex: navDrawerIndex,
      // Mandarlo a otra pantalla
      onDestinationSelected: (value) {
        setState(() {
          // Actualizar el valor de la opcion seleccionada
          navDrawerIndex=value;
          // Saber que opcion del arreglo es
          final menuItem=appMenuItems[value];
          // Abrir pantalla
          context.push(menuItem.link);
          // Cerrar el side_menu
          widget.scaffoldKey.currentState?.closeDrawer();
        });
      },
      children: [
        // Adaptar el padding de arriba
        Padding(padding: EdgeInsets.fromLTRB(28,hasNotch?10:20,10,10), child: Text('EasyCountCol',style: titleStyle),),
        // Itera el arreglo de menuiteams para generar
        ...appMenuItems.sublist(0,4).map((item)=>NavigationDrawerDestination(icon: Icon(item.icon) , label: Text(item.title))),
        Padding(padding: EdgeInsets.fromLTRB(28, 16, 16, 10), child: Divider(),),
        Padding(padding: EdgeInsets.fromLTRB(28,10,16,10), child: const Text('Mas de opciones'),),     
        ...appMenuItems.sublist(4,6).map((item)=>NavigationDrawerDestination(icon: Icon(item.icon) , label: Text(item.title))),

      ]);
  }
}