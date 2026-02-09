import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/contact.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(ref.read(dioProvider));
});

class ContactsRepository {
  final Dio _dio;

  ContactsRepository(this._dio);

  /// Fetch all contacts with optional pagination
  Future<List<Contact>> getContacts({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.contacts,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseList<Contact>(response.data, Contact.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Helper to parse list responses
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
