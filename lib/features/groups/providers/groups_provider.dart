import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/group.dart';

final groupsProvider =
    AsyncNotifierProvider<GroupsNotifier, List<Group>>(GroupsNotifier.new);

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() => fetchGroups();

  Future<List<Group>> fetchGroups() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.groups);
      final data = response.data;

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => Group.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => Group.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchGroups);
  }
}

final groupDetailProvider = FutureProvider.family<Group?, String>(
  (ref, groupId) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.group(groupId));
      final data = response.data;

      if (data is Map) {
        final groupData = data['data'] ?? data;
        return Group.fromJson(groupData as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  },
);
