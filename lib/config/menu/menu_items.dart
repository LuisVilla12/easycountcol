// Crear las opciones del menu
import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final String link;
  final IconData icon;

// Clase de inicializar
const MenuItem({
  required this.title,
  required this.subtitle,
  required this.link,
  required this.icon,
});
}
// Definir los iteams
const appMenuItems=<MenuItem>[
  // MenuItem(
  //   title:'Tutorial' ,
  //   subtitle: 'Inicio de la aplicación móvil',
  //   link: '/tutorial',
  //   icon:Icons.school ,
  // ),  
  MenuItem(
    title:'Inicio' ,
    subtitle: 'Pagina principal de la aplicación movil',
    link: '/home',
    icon:Icons.home ,
  ),    
  MenuItem(
    title:'Historial' ,
    subtitle: 'Registro de todas las muestras ',
    link: '/history',
    icon:Icons.menu_book_sharp ,
  ),  
  MenuItem(
    title:'Configuración' ,
    subtitle: 'Personalización de la aplicación',
    link: '/config',
    icon:Icons.settings,
  ),
    MenuItem(
    title:'Cerrar sesión' ,
    subtitle: 'Cerrar sesión',
    link: '/logout',
    icon:Icons.logout_outlined ,
  ),   
];