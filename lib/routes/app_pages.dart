import 'package:creditsea/modules/loan/bindings/calculator_binding.dart';
import 'package:creditsea/modules/loan/bindings/offer_binding.dart';
import 'package:creditsea/modules/loan/bindings/status_binding.dart';
import 'package:creditsea/modules/loan/views/calculator_view.dart';
import 'package:creditsea/modules/loan/views/offer_view.dart';
import 'package:creditsea/modules/loan/views/status_view.dart';
import 'package:creditsea/modules/onboarding/bindings/email_binding.dart';
import 'package:creditsea/modules/onboarding/bindings/pan_binding.dart';
import 'package:creditsea/modules/onboarding/views/email_view.dart';
import 'package:creditsea/modules/onboarding/views/pan_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/bindings/create_password_binding.dart';
import '../modules/auth/bindings/otp_binding.dart';
import '../modules/auth/bindings/sign_in_binding.dart';
import '../modules/auth/views/create_account_view.dart';
import '../modules/auth/views/create_password_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/sign_in_view.dart';
import '../modules/onboarding/bindings/personal_details_binding.dart';
import '../modules/onboarding/views/personal_details_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
        name: Routes.splash,
        page: () => const SplashView(),
        binding: SplashBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.createAccount,
        page: () => const CreateAccountView(),
        binding: CreateAccountBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.otp,
        page: () => const OtpView(),
        binding: OtpBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.createPassword,
        page: () => const CreatePasswordView(),
        binding: CreatePasswordBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.signIn,
        page: () => const SignInView(),
        binding: SignInBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.personalDetails,
        page: () => const PersonalDetailsView(),
        binding: PersonalDetailsBinding(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.email,
        page: () => const EmailView(),
        binding: EmailBinding(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.pan,
        page: () => const PanView(),
        binding: PanBinding(),
        transition: Transition.rightToLeft),
GetPage(name: Routes.calculator, page: () => const CalculatorView(), binding: CalculatorBinding(), transition: Transition.fadeIn),
GetPage(name: Routes.offer, page: () => const OfferView(), binding: OfferBinding(), transition: Transition.rightToLeft),
GetPage(name: Routes.status, page: () => const StatusView(), binding: StatusBinding(), transition: Transition.rightToLeft),
  ];
}
