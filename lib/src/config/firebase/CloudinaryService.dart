import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  late CloudinaryPublic _cloudinary;

  // Initialize with your Cloudinary credentials
  // Get free account at: https://cloudinary.com
  void initialize({
    required String cloudName,
    required String uploadPreset,
  }) {
    _cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );
  }

  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'freedz/profiles',
          resourceType: CloudinaryResourceType.Image,
          identifier: 'profile_$userId',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload profil: $e');
    }
  }

  /// Upload portfolio image
  Future<String> uploadPortfolioImage(
    File imageFile,
    String userId,
    String projectId,
  ) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'freedz/portfolio/$userId',
          resourceType: CloudinaryResourceType.Image,
          identifier: 'portfolio_${projectId}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload portfolio: $e');
    }
  }

  /// Upload job attachment image
  Future<String> uploadJobImage(File imageFile, String jobId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'freedz/jobs',
          resourceType: CloudinaryResourceType.Image,
          identifier: 'job_${jobId}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload job: $e');
    }
  }

  /// Upload chat image
  Future<String> uploadChatImage(File imageFile, String chatId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'freedz/chat',
          resourceType: CloudinaryResourceType.Image,
          identifier: 'chat_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erreur upload chat: $e');
    }
  }

  /// Delete image by public ID
  Future<void> deleteImage(String publicId) async {
    try {
      await _cloudinary.deleteFile(
        publicId: publicId,
        resourceType: CloudinaryResourceType.Image,
        invalidate: true,
      );
    } catch (e) {
      throw Exception('Erreur suppression image: $e');
    }
  }

  /// Get optimized image URL
  String getOptimizedUrl(
    String imageUrl, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    // Cloudinary automatically optimizes if you use their URL structure
    // Example: https://res.cloudinary.com/demo/image/upload/w_400,h_400,c_fill,q_auto/sample.jpg
    
    if (!imageUrl.contains('cloudinary.com')) return imageUrl;
    
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('c_fill'); // Crop to fill
    
    final transformation = transformations.join(',');
    
    return imageUrl.replaceFirst(
      '/upload/',
      '/upload/$transformation/',
    );
  }
}