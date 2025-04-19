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
    title:'Tutorial' ,
    subtitle: 'Inicio de la aplicación móvil',
    link: '/tutorial',
    icon:Icons.smart_button_outlined ,
  ),  
  MenuItem(
    title:'Inicio' ,
    subtitle: 'Pagina principal de la aplicación movil',
    link: '/home',
    icon:Icons.credit_card ,
  ),    
  MenuItem(
    title:'Historial' ,
    subtitle: 'Registro de todas las muestras ',
    link: '/history',
    icon:Icons.access_alarm ,
  ),  
  MenuItem(
    title:'Resultados' ,
    subtitle: 'Analisis de la muestra',
    link: '/results',
    icon:Icons.access_alarm ,
  ),
  MenuItem(
    title:'Configuración' ,
    subtitle: 'Personalización de la aplicación',
    link: '/config',
    icon:Icons.access_alarm ,
  ),
  MenuItem(
    title:'Iniciar sesión' ,
    subtitle: 'Accede a tu cuenta',
    link: '/config',
    icon:Icons.access_alarm ,
  ),    
];