import 'dart:io';

import 'package:easycoutcol/config/menu/side_menu.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:easycoutcol/config/services/camera_services_implementation.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  static const String name='home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Saber la referencia actual
    final scaffoldKey=GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Inicio'),),
        drawer: SideMenu(scaffoldKey: scaffoldKey),
        body: _viewCamera() ,
      ),
    );
  }
}

class _viewCamera extends StatefulWidget {
  const _viewCamera({
    super.key,
  });

  @override
  State<_viewCamera> createState() => _viewCameraState();
}


class _viewCameraState extends State<_viewCamera> with TickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  String nameSample='';  
  String typeSample='';  
  String factorSample='';  
  String volumenSample='';  
  String imagePath='';  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener((){
      // cambiar el state del tab
      setState(() {});
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

Widget buildImageView() {
  if (imagePath == null) return const SizedBox.shrink();

  final file = File(imagePath);
  if (!file.existsSync()) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text("La imagen no existe o no se pudo cargar."),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Image.file(
      file,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding:  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: formKeySample,
        child: Column(
          children: [
            const Text(
              'Registro de muestra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Complete la información necesaria'),
            const SizedBox(height: 12),
            InputCustom(
              labelInput: 'Nombre de la muestra',hintInput: 'Ingrese el nombre de la muestra',
              iconInput: Icon(Icons.label_important,color: colors.primary),
              onChanged: (value){
                nameSample=value;
                formKeySample.currentState?.validate();
              },
              validator: (value){
                if(value==null || value.isEmpty) return 'El campo es requerido.';
                if(value.length<1) return 'El campo debe  tener una longitud valida.';              return null;
              } ,
            ),
            const SizedBox(height: 12),
            InputCustom(
              labelInput: 'Tipo de muestra',hintInput: 'Ingrese el tipo de muestra',
              iconInput: Icon(Icons.category,color: colors.primary),
              onChanged: (value){
                typeSample=value;
                formKeySample.currentState?.validate();
              },
              validator: (value){
                if(value==null || value.isEmpty) return 'El campo es requerido.';
                if(value.length<2) return 'El campo debe  tener una longitud valida.';              return null;
              } ,
            ),
            const SizedBox(height: 12),
            InputCustom(
              labelInput: 'Volumen de sembrado',hintInput: 'Ingrese el volumen de sembrado de la muestra',
              iconInput: Icon(Icons.local_drink,color: colors.primary),
              onChanged: (value){
                volumenSample=value;
                formKeySample.currentState?.validate();
              },
              validator: (value){
                if(value==null || value.isEmpty) return 'El campo es requerido.';
                if(value.length<2) return 'El campo debe  tener una longitud valida.';              return null;
              } ,
            ),
            const SizedBox(height: 12,),
            InputCustom(
              labelInput: 'Factor de dilución',hintInput: 'Ingrese el factor de dilución la muestra',
              iconInput: Icon(Icons.science,color: colors.primary),
              onChanged: (value){
                volumenSample=value;
                formKeySample.currentState?.validate();
              },
              validator: (value){
                if(value==null || value.isEmpty) return 'El campo es requerido.';
                if(value.length<2) return 'El campo debe  tener una longitud valida.';              return null;
              } ,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}), // Importante para refrescar
              tabs: const [
                Tab(text: 'Cámara'),
                Tab(text: 'Subir'),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              
              child: _tabController.index == 0?
            Center(
              child:  Column(
                children: [
                  const SizedBox(height: 5,),
                  FilledButton.icon(onPressed: (){
                    showCaptureRecommendations(context);
                    
                  },icon: const Icon(Icons.camera_alt_rounded), label: imagePath==''? const Text('Capturar una imagen'):const Text('Volver a tomar una imagen')),
              ]),     
              ): Center(
                child:  Column(
                  children: [
                  const SizedBox(height: 5,),
                  FilledButton.icon(onPressed: () async{
                  final photoPath=await CameraServicesImplementation().selectPhoto();
                    if(photoPath==null) return null;
                    photoPath;
                    setState(() {
                    imagePath = photoPath;
                    });
                  },icon: const Icon(Icons.photo_library_sharp), label: imagePath==''? const Text('Seleccionar una imagen'):const Text('Volver a seleccionar una imagen')),
              ]),
              ),
            ), buildImageView(),

          const SizedBox(height: 20,),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
              // Verificar si esta validado o no
              final isValid=formKeySample.currentState!.validate();
              // Sino esta vlialoidadno no hacer nada
              if(!isValid) return;
              if (!context.mounted) return;},
              icon: const Icon(Icons.save), 
              label:const Text('Registarse' ),
              style: FilledButton.styleFrom(    
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), 
                // Sin bordes redondeados
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), ),)),
          ),
            const SizedBox(height: 20,)
            ],
        ),
      ),
    );
  }
  void showCaptureRecommendations(BuildContext context) {
  final colors=Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: colors.primary),
          const SizedBox(width: 8),
          const Text('Recomendaciones'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.wb_sunny_outlined, color: Colors.amber),
              title: Text('Iluminación'),
              subtitle: Text(
                'Asegúrate de tener buena iluminación uniforme. Evita sombras y reflejos directos sobre la placa.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.social_distance, color: Colors.green),
              title: Text('Distancia'),
              subtitle: Text(
                'Mantén la cámara a una distancia de 15–20 cm de la placa para capturar todos los detalles.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.center_focus_strong, color: Colors.blue),
              title: Text('Enfoque'),
              subtitle: Text(
                'Asegúrate de que la imagen esté bien enfocada. Toca la pantalla para ajustar el enfoque si es necesario.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.crop_square, color: Colors.purple),
              title: Text('Posición'),
              subtitle: Text(
                'Coloca la placa de Petri dentro del marco guía. Mantén la cámara paralela a la superficie de la placa.',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Card(
                color: Color(0xFFF0F4F8),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '💡 Consejo profesional: Para obtener resultados óptimos, utiliza un fondo blanco o negro uniforme detrás de la placa.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Cierra el modal
            final photoPath = await CameraServicesImplementation().takePhoto();
            if (photoPath == null) return;
            setState(() {
              imagePath = photoPath;
            });
          },
          child: const Text('Entendido, capturar imagen'),
        ),
      ],
    ),
  );
}

}
