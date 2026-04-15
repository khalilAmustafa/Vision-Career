// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fillFields => 'يرجى تعبئة جميع الحقول';

  @override
  String loginFailed(Object error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get username => 'اسم المستخدم';

  @override
  String get age => 'العمر';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get invalidAge => 'أدخل عمرًا صحيحًا';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String registerFailed(Object error) {
    return 'فشل التسجيل: $error';
  }

  @override
  String get joinVisionCareer => 'انضم إلى Vision Career';

  @override
  String get loginSubtitle => 'سجل الدخول للمتابعة';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get or => 'أو';

  @override
  String get appName => 'مسار';
}
