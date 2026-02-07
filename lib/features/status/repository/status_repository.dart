import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/status_update.dart';

final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  return StatusRepository(ref.read(dioProvider));
});

class StatusRepository {
  final Dio _dio;

  StatusRepository(this._dio);

  /// Fetch all statuses grouped by contact
  Future<List<ContactStatus>> getStatuses() async {
    try {
      final response = await _dio.get(ApiConstants.status);
      return _parseList<ContactStatus>(response.data, ContactStatus.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Post a text status
  Future<StatusUpdate?> postTextStatus({
    required String text,
    String? backgroundColor,
    String? textColor,
    DateTime? scheduledAt,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.status,
        data: {
          'type': 'text',
          'text': text,
          if (backgroundColor != null) 'background_color': backgroundColor,
          if (textColor != null) 'text_color': textColor,
          if (scheduledAt != null)
            'scheduled_at': scheduledAt.toIso8601String(),
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final statusData = data['data'] ?? data;
        if (statusData is Map<String, dynamic>) {
          return StatusUpdate.fromJson(statusData);
        }
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Post an image status
  Future<StatusUpdate?> postImageStatus({
    required String filePath,
    String? caption,
    DateTime? scheduledAt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': 'image',
        'file': await MultipartFile.fromFile(filePath),
        if (caption != null) 'caption': caption,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toIso8601String(),
      });

      final response = await _dio.post(
        ApiConstants.status,
        data: formData,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final statusData = data['data'] ?? data;
        if (statusData is Map<String, dynamic>) {
          return StatusUpdate.fromJson(statusData);
        }
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Post a video status
  Future<StatusUpdate?> postVideoStatus({
    required String filePath,
    String? caption,
    DateTime? scheduledAt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': 'video',
        'file': await MultipartFile.fromFile(filePath),
        if (caption != null) 'caption': caption,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toIso8601String(),
      });

      final response = await _dio.post(
        ApiConstants.status,
        data: formData,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final statusData = data['data'] ?? data;
        if (statusData is Map<String, dynamic>) {
          return StatusUpdate.fromJson(statusData);
        }
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Delete a status
  Future<bool> deleteStatus(String statusId) async {
    try {
      await _dio.delete(ApiConstants.statusById(statusId));
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Mark status as viewed
  Future<void> markAsViewed(String statusId) async {
    try {
      await _dio.post('${ApiConstants.statusById(statusId)}/view');
    } on DioException catch (_) {
      // Silently fail — viewing is non-critical
    }
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
