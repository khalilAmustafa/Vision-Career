// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create account';

  @override
  String get fillFields => 'Please fill in all fields.';

  @override
  String loginFailed(Object error) {
    return 'Login failed: $error';
  }

  @override
  String get username => 'Username';

  @override
  String get age => 'Age';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get invalidAge => 'Enter a valid age.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get accountCreated => 'Account created successfully.';

  @override
  String registerFailed(Object error) {
    return 'Register failed: $error';
  }

  @override
  String get joinVisionCareer => 'Join Vision Career';
}
