import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadScanImage(String userId, String scanId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users/$userId/scans/$scanId.jpg');
      
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  Future<void> deleteScanImage(String userId, String scanId) async {
    try {
      final ref = _storage.ref().child('users/$userId/scans/$scanId.jpg');
      await ref.delete();
    } catch (e) {
      // If the file doesn't exist, we can ignore the error
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      throw Exception('Failed to delete image from Firebase Storage: $e');
    }
  }
  
  Future<void> deleteAllUserImages(String userId) async {
    try {
        final dirRef = _storage.ref().child('users/$userId/scans');
        final listResult = await dirRef.listAll();
        
        await Future.wait(listResult.items.map((item) => item.delete()));
    } catch (e) {
         // Folders aren't real in Firebase Storage, so listAll on an empty path might just return empty or error depending on structure.
         // Ignore error if folder doesn't exist or is empty
    }
  }
}
