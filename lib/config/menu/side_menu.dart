import 'package:easycoutcol/config/menu/menu_items.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasNotch = MediaQuery.of(context).viewPadding.top > 25;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );

    // Saber el usuario con riverpod
    final name = ref.watch(nameProvider);
    final lastName = ref.watch(lastnameProvider); 

    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      indicatorColor: colors.primary,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;
        });
        final menuItem = appMenuItems[value];
        Future.delayed(const Duration(milliseconds: 150), () {
          context.push(menuItem.link);
        });
        widget.scaffoldKey.currentState?.closeDrawer();
      },
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 10 : 40, 10, 10),
          child: Column(
            children: [
              Text('$name $lastName', style: titleStyle?.copyWith(fontSize: 20)),
              Text('Bienvenido de nuevo', style: titleStyle?.copyWith(fontSize: 14,fontWeight:FontWeight.normal)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 15),
          child: const Text('NAVEGACIÓN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        // Muestra las primeras tres opciones del menú
        ...appMenuItems.asMap().entries.where((entry)=> entry.key<=2).map((entry) {
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
                color: navDrawerIndex == index ? Colors.white : colors.primary, fontSize: 15,
              ),
            ),
          );
        }),
        Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 16, 0),
          child: Divider(
            color: colors.primary.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
          child: const Text('PREFERENCIAS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        // Muestra las siguientes opciones del menú 
        ...appMenuItems.asMap().entries.where((entry)=> entry.key>2 && entry.key<4).map((entry) {
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
                color: navDrawerIndex == index ? Colors.white : colors.primary,fontSize: 15,
              ),
            ),
          );
        }),
        Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 16, 0),
          child: Divider(
            color: colors.primary.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
          child: const Text('CUENTA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        ...appMenuItems.asMap().entries.where(
          (entry){
            final item = entry.value;

            if (entry.key <= 3 || entry.key >= 6) return false;
            if (nameProvider == '' && item.link == '/logut') return false;
            if (nameProvider != '' && item.link == '/login') return false;
            return true;
          }).map((entry) {
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
        }),
        Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 16, 0),
          child: Divider(
            color: colors.primary.withOpacity(0.5),
          ),
        ),
        ...appMenuItems.asMap().entries.where(
          (entry)=>entry.key>5).map((entry) {
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
        }),
        const SizedBox(height: 20),
        Center(child: const Text('VERSION: 2.1.0', style: TextStyle(fontSize: 12)))
      ],
    );
  }
}
