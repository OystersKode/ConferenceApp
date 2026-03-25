import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String _cloudName = 'dfx4py1jf';
  static const String _uploadPreset = 'profile_photo_upload';

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Uploads an image (profile photo) to Cloudinary using bytes for web compatibility
  Future<String?> uploadProfilePhoto(Uint8List bytes, String userId) async {
    try {
      final String uniquePublicId = 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // CloudinaryPublic uses fromByteData for raw bytes
      final byteData = ByteData.view(bytes.buffer);

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          byteData,
          identifier: 'profile_photo_$userId',
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
  Future<String?> uploadResource(Uint8List bytes, String fileName) async {
    try {
      final byteData = ByteData.view(bytes.buffer);
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          byteData,
          identifier: fileName,
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
