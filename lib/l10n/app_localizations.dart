import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Portal'**
  String get appTitle;

  /// No description provided for @facultyName.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Engineering'**
  String get facultyName;

  /// No description provided for @studentPortal.
  ///
  /// In en, this message translates to:
  /// **'Student Portal'**
  String get studentPortal;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select your year'**
  String get selectYear;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password ?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account ?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @gba.
  ///
  /// In en, this message translates to:
  /// **'GBA'**
  String get gba;

  /// No description provided for @completedCreditHours.
  ///
  /// In en, this message translates to:
  /// **'Completed Credit Hours'**
  String get completedCreditHours;

  /// No description provided for @remainingCreditHours.
  ///
  /// In en, this message translates to:
  /// **'Remaining Credit Hours'**
  String get remainingCreditHours;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @courseRegistration.
  ///
  /// In en, this message translates to:
  /// **'Course Registration'**
  String get courseRegistration;

  /// No description provided for @courseDetails.
  ///
  /// In en, this message translates to:
  /// **'Course Details'**
  String get courseDetails;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @myGrades.
  ///
  /// In en, this message translates to:
  /// **'My Grades'**
  String get myGrades;

  /// No description provided for @yourCourses.
  ///
  /// In en, this message translates to:
  /// **'Your Courses'**
  String get yourCourses;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search ...'**
  String get search;

  /// No description provided for @level1Semester1.
  ///
  /// In en, this message translates to:
  /// **'Level 1 - Semester (1)'**
  String get level1Semester1;

  /// No description provided for @level1Semester2.
  ///
  /// In en, this message translates to:
  /// **'Level 1 - Semester (2)'**
  String get level1Semester2;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get students;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @universityName.
  ///
  /// In en, this message translates to:
  /// **'Al-Azhar University'**
  String get universityName;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Computer Systems Engineering'**
  String get department;

  /// No description provided for @academicSummary.
  ///
  /// In en, this message translates to:
  /// **'Academic Summary'**
  String get academicSummary;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @receiveAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive app notifications'**
  String get receiveAppNotifications;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @creditHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit Hours : {hours}'**
  String creditHoursLabel(int hours);

  /// No description provided for @prerequisites.
  ///
  /// In en, this message translates to:
  /// **'Prerequisites'**
  String get prerequisites;

  /// No description provided for @courseFull.
  ///
  /// In en, this message translates to:
  /// **'Course is full'**
  String get courseFull;

  /// No description provided for @courseConflict.
  ///
  /// In en, this message translates to:
  /// **'Course conflict detected'**
  String get courseConflict;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @yourYear.
  ///
  /// In en, this message translates to:
  /// **'Your year'**
  String get yourYear;

  /// No description provided for @major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @noLectures.
  ///
  /// In en, this message translates to:
  /// **'No lectures for this day'**
  String get noLectures;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @creditHours.
  ///
  /// In en, this message translates to:
  /// **'Credit Hours'**
  String get creditHours;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @contactAcademicAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Contact Academic Advisor'**
  String get contactAcademicAdvisor;

  /// No description provided for @advisorGreeting.
  ///
  /// In en, this message translates to:
  /// **'How can I help you?'**
  String get advisorGreeting;

  /// No description provided for @advisorMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message...'**
  String get advisorMessageHint;

  /// No description provided for @advisorTyping.
  ///
  /// In en, this message translates to:
  /// **'Academic advisor is typing...'**
  String get advisorTyping;

  /// No description provided for @advisorThanksMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for contacting us. The academic advisor will contact you soon.'**
  String get advisorThanksMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
