import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Replace with your Cloudinary credentials
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  /// Uploads an image (profile photo) to Cloudinary
  Future<String?> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_photos',
          publicId: userId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Image Upload Error: $e');
      return null;
    }
  }

  /// Uploads a resource (PPT, PDF) to Cloudinary
  Future<String?> uploadResource(File file, String fileName) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'conference_resources',
          publicId: fileName,
          resourceType: CloudinaryResourceType.Auto, // Auto detects PDF/PPT
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Resource Upload Error: $e');
      return null;
    }
  }
}
