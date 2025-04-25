import 'package:easycoutcol/config/menu/menu_items.dart';
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
    final colors=Theme.of(context).colorScheme;
    // Saber el padding top
    final hasNotch=MediaQuery.of(context).viewPadding.top>25;
    final titleStyle=Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  );

    return NavigationDrawer(
      // Saber que opcion selecciono
      selectedIndex: navDrawerIndex,
      indicatorColor: colors.primary, // Aquí defines el color para la opción seleccionada
      // Mandarlo a otra pantalla
      onDestinationSelected: (value) {
        setState(() {
          // Actualizar el valor de la opcion seleccionada
          navDrawerIndex=value;
        });
         // Saber que opcion del arreglo es
          final menuItem=appMenuItems[value];
          // Cerrar el side_menu
          widget.scaffoldKey.currentState?.closeDrawer();

          Future.delayed(const Duration(milliseconds: 150), () {
            context.push(menuItem.link);
          });
      },
      children: [
        // Adaptar el padding de arriba
        Padding(padding: EdgeInsets.fromLTRB(28,hasNotch?10:40,10,10), child: Text('EasyCountCol',style: titleStyle),),
        // Itera el arreglo de menuiteams para generar
        ...appMenuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return NavigationDrawerDestination(
              icon: Icon(
                item.icon,
                color: navDrawerIndex == index ? Colors.white : colors.primary,
              ),
              label: Text(
                item.title,
                style: TextStyle(
                  color: navDrawerIndex == index ? Colors.white : colors.primary,
                ),
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.fromLTRB(28, 16, 16, 10), child: Divider(),),
        // Padding(padding: EdgeInsets.fromLTRB(28,10,16,10), child: const Text('Mas de opciones'),),     
        // ...appMenuItems.sublist(4,6).map((item)=>NavigationDrawerDestination(icon: Icon(item.icon) , label: Text(item.title))),

      ]);
  }
}