/// Routes for the application
///
/// This class contains all the routes used in the application.
class ApplicationRoutesConstants {
  static const home = '/home';
  static const schedule = '/home/schedule';
  static const profile = '/home/profile';

  // Auth routes
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';
  static const onboarding = '/onboarding';

  // Account routes
  static const account = '/account';

  // orders routes
  static const orders = '/orders';
  static const orderDetails = '/orders/details';
  static const orderHistory = '/orders/history';
  static const orderTracking = '/orders/tracking';
  static const orderCancellation = '/orders/cancellation';

  // Settings routes
  static const settings = '/settings';

  // Error routes
  static const notFound = '/not-found';
  static const unauthorized = '/unauthorized';
  static const noInternet = '/no-internet';
  static const maintenance = '/maintenance';
  static const serverError = '/server-error';
  static const badRequest = '/bad-request';
  static const comingSoon = '/coming-soon';
  static const underConstruction = '/under-construction';
  static const error = '/error';
  static const error500 = '/error/500';
}
