import 'package:animate_do/animate_do.dart';
import 'package:easycoutcol/config/presentation/screens/auth/demo_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlidesInfo {
  final String title;
  final String caption;
  final Icon iconName;

  SlidesInfo(
      {required this.title, required this.caption, required this.iconName});
}

// Definir imagenes
final slides = <SlidesInfo>[
  SlidesInfo(
      title: 'Bienvenido a EasyCountCol',
      caption:
          'La aplicación para el cálculo y seguimiento de Unidades Formadoras de Colonias.',
      iconName: const Icon(Icons.calculate_outlined)),
  SlidesInfo(
      title: 'Realiza cálculos precisos',
      caption:
          'Calcula concentraciones de UFC con nuestra interfaz intuitiva y fórmulas avanzadas.',
      iconName: const Icon(Icons.stacked_line_chart)),
  SlidesInfo(
      title: 'Captura tus placas',
      caption:
          'Toma fotos de tus placas de Petri o sube imágenes para análisis automático.',
      iconName: const Icon(Icons.add_a_photo_outlined)),
  SlidesInfo(
      title: 'Guarda tu historial',
      caption:
          'Mantén un registro completo de todos tus experimentos y resultados.',
      iconName: const Icon(Icons.filter_drama_outlined)),
];

class TutorialScreen extends StatefulWidget {
  static const String name = 'tutorial_screen';
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  // Definir el controller del pageView
  final PageController pageViewController=PageController(initialPage: 0);
  // Saber si ya llego al final
  bool endTutorial=false;
  int activePage=0;

  // Ciclo de state del StateFullWidget
  @override
  void initState() {
    super.initState();
    // Añadir un add evelistener a la contoladora
    pageViewController.addListener((){
      // Saber en que pagina esta
      // print('${pageViewController.page}');
      final page=pageViewController.page??0;
      if(!endTutorial&& page>=(slides.length-1.4)){
        // Solo se va a utilizar una ves esa condicion
        setState(() {
          endTutorial=true;
        });
      }
    });
  }
  // Eliminar los states
  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors=Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            // Asignar el controlador
            controller: pageViewController,
              physics: const BouncingScrollPhysics(),
              // Saber si una pagina cambio
              onPageChanged: (int index) {setState(() {activePage = index;});},
              // Slides del page view
              children: slides
                  .map((slideData) => _Slide(
                      title: slideData.title,
                      caption: slideData.caption,
                      iconName: slideData.iconName))
                  .toList()),
          // Boton de saltar
          Positioned(
              right: 20,
              top: 50,
              child: TextButton(
                  onPressed: () => context.pushNamed(LoginScreen.name),
                  child: const Text('Saltar'))),
                  Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: activePage == index ? 12 : 8,
                    height: activePage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: activePage == index ? colors.primary : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                  }),
                  ),
              ),
              // Boton para empezar
              endTutorial?
              Positioned(
                bottom: 30,
                right: 30,
                // Animación  de fade
                child: FadeInRight(
                  // desde 15 puntos
                  from: 15,
                  // Retraso
                  delay: const Duration(seconds: 1),
                  child: FilledButton(onPressed: ()=>context.pushNamed(LoginScreen.name), child: const Text('Comenzar')))):const SizedBox()
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String caption;
  final Icon iconName;
  const _Slide(
      {required this.title, required this.caption, required this.iconName});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final captionStyle = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: IconButton.filled(
              onPressed: () {},
              icon: iconName,
              iconSize: 50,
              style: ButtonStyle(
                padding:
                    WidgetStateProperty.all(const EdgeInsets.all(30)), // opcional
              ),
            ),
          ),
          Text(
            title,
            style: titleStyle,
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              caption,
              style: captionStyle,
            ),
          )
        ],
      ),
    );
  }
}
