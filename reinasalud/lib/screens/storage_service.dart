import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Sube una imagen a una carpeta específica y devuelve la URL pública
  Future<String?> uploadImage({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? DateTime.now().toIso8601String();
      final ref = _storage.ref().child(folder).child('$name.jpg');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }
}
