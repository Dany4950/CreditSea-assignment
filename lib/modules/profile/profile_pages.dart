import 'package:get/get.dart';

import 'bindings/profile_binding.dart';
import 'views/profile_view.dart';

abstract class ProfileRoutes {
  static const profile = '/profile';
}

/// Spread into AppPages.pages:   ...ProfilePages.pages,
abstract class ProfilePages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: ProfileRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
