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
  MenuItem(
    title:'Inicio' ,
    subtitle: 'Pagina principal de la aplicación movil',
    link: '/home',
    icon:Icons.home_outlined ,
  ),    
  MenuItem(
    title:'Historial' ,
    subtitle: 'Registro de todas las muestras ',
    link: '/history',
    icon:Icons.history_outlined ,
  ), 
  MenuItem(
    title:'Configuración' ,
    subtitle: 'Configuración de la aplicación',
    link: '/config',
    icon:Icons.settings_outlined,
  ), 
  MenuItem(
    title:'Personalizar tema' ,
    subtitle: 'Personalización de la aplicación',
    link: '/theme',
    icon:Icons.color_lens_outlined,
  ),
  MenuItem(
    title:'Iniciar sesión' ,
    subtitle: 'Iniciar sesión',
    link: '/login',
    icon:Icons.login_outlined ,
  ),   
    MenuItem(
    title:'Cerrar sesión' ,
    subtitle: 'Cerrar sesión',
    link: '/logout',
    icon:Icons.logout_outlined ,
  ),  
    MenuItem(
    title:'Ayuda y soporte' ,
    subtitle: 'Apoyo y soporte técnico',
    link: '/help',
    icon:Icons.question_answer_outlined ,
  ),  
];