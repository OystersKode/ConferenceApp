import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = 'dfx4py1jf';
  static const String _uploadPreset = 'profile_photo_upload';

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Uploads an image (profile photo) to Cloudinary
  Future<String?> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      // Using a unique publicId by appending timestamp to force a new URL/prevent overwriting cache issues
      final String uniquePublicId = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_photos',
          publicId: uniquePublicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      print('Cloudinary Upload Success: ${response.secureUrl}');
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
          resourceType: CloudinaryResourceType.Auto,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Resource Upload Error: $e');
      return null;
    }
  }
}
