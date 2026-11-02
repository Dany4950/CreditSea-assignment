import 'package:creditsea/modules/profile/repositories/api_profile_repository.dart';

import '../../modules/auth/repositories/api_auth_repository.dart';
import '../../modules/loan/repositories/api_loan_repository.dart';
import '../../modules/onboarding/repositories/api_onboarding_repository.dart';

/// Registers the real repositories (replaces every Mock*Repository). Call after registerApis().
void registerRepositories() {
  registerApiAuthRepository();
  registerApiOnboardingRepository();
  registerApiLoanRepository();
  registerApiProfileRepository();
}
