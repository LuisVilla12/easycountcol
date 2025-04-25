import 'package:easycoutcol/config/services/camera_service.dart';
import 'package:image_picker/image_picker.dart';


class CameraServicesImplementation extends CameraService{
  final ImagePicker picker = ImagePicker();
  @override
  Future<String?> selectPhoto()async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery, 
      // Calidad de la imagen
      imageQuality: 10,
      // Que camara prefiere
      preferredCameraDevice: CameraDevice.rear);
      if(photo==null) return null;
      print('Tenemos una imagen ${photo.path}');
      return photo.path;
  }

  @override
  Future<String?> takePhoto() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera, 
      // Calidad de la imagen
      imageQuality: 80,
      // Que camara prefiere
      preferredCameraDevice: CameraDevice.rear);
      if(photo==null) return null;
      print('Tenemos una imagen ${photo.path}');
      return photo.path;
  }

}