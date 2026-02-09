import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/models/profile.dart';

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, Profile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() async {
    return _fetchProfile();
  }

  Future<Profile> _fetchProfile() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(ApiConstants.profile);
    return Profile.fromJson(response.data);
  }

  Future<void> updateProfile({
    String? name,
    String? about,
    String? businessName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (about != null) updateData['about'] = about;
      if (businessName != null) updateData['business_name'] = businessName;

      final response = await dio.patch(
        ApiConstants.profile,
        data: updateData,
      );

      final updatedProfile = Profile.fromJson(response.data);
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _fetchProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
