// Definir las funciones de la camara
abstract class CameraService {
  Future<String?> takePhoto();
  Future<String?> selectPhoto();
}