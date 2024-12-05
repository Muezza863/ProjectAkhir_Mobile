import 'package:image_picker/image_picker.dart';

class ImagePickerServices {
  final ImagePicker _picker = ImagePicker();

  void getImageFromGallery(Function(String?) callbackFunc) async{
    try {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery
      );
      callbackFunc(pickedFile?.path);
    }catch (e){
      print("Error : $e");
    }
  }

  void  getImageFromCamera(Function(String?) callbackFunc) async{
    try {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front
      );
      callbackFunc(pickedFile?.path);
    }catch (e){
      print("Error : $e");
    }
  }
}