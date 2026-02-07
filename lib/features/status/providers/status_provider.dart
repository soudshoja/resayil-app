import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/status_update.dart';

final statusProvider =
    AsyncNotifierProvider<StatusNotifier, List<ContactStatus>>(
        StatusNotifier.new);

class StatusNotifier extends AsyncNotifier<List<ContactStatus>> {
  @override
  Future<List<ContactStatus>> build() => fetchStatuses();

  Future<List<ContactStatus>> fetchStatuses() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.status);
      final data = response.data;

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => ContactStatus.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => ContactStatus.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchStatuses);
  }
}
