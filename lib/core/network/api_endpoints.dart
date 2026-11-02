/// Every backend path in one place (relative to AppConfig.baseUrl, which already ends in /api).
abstract class ApiEndpoints {
  static const health = '/health';

  // auth
  static const requestOtp = '/auth/request-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const setPassword = '/auth/set-password';
  static const login = '/auth/login';
  static const logout = '/auth/logout';

  // user
  static const profile = '/user/profile';

  // onboarding
  static const personal = '/onboarding/personal';
  static const email = '/onboarding/email';
  static const emailSendOtp = '/onboarding/email/send-otp';
  static const emailVerify = '/onboarding/email/verify';
  static const pan = '/onboarding/pan';
  static const panVerify = '/onboarding/pan/verify';

  // loans
  static const eligibility = '/loans/eligibility';
  static const quote = '/loans/quote';
  static const apply = '/loans/apply';
  static const loans = '/loans';
  static String loanById(String id) => '/loans/$id';
  static String acceptLoan(String id) => '/loans/$id/accept';
}
