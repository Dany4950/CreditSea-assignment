import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/user_profile.dart';

class UserApi {
  UserApi(this._client);
  final ApiClient _client;

  /// Used by the splash screen (`profileComplete` decides the first route) and the Profile screen.
  Future<UserProfile> getProfile() => _client.getObject(ApiEndpoints.profile, UserProfile.fromJson);

  Future<UserProfile> updateProfile(UpdateProfileRequest r) =>
      _client.putObject(ApiEndpoints.profile, UserProfile.fromJson, data: r.toJson());
}
