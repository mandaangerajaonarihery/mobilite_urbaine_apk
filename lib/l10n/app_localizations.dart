import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Hiditra'**
  String get startButton;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manavao ny Fitantanana ny Fitaterana an-tanàn-dehibe'**
  String get landingTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Hiditra'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Hivoaka'**
  String get logout;

  /// No description provided for @connectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Niala soa aman-tsara'**
  String get connectedSuccess;

  /// No description provided for @languageFr.
  ///
  /// In en, this message translates to:
  /// **'Frantsay'**
  String get languageFr;

  /// No description provided for @languageMg.
  ///
  /// In en, this message translates to:
  /// **'Malagasy'**
  String get languageMg;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Mazava'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Maizina'**
  String get darkMode;

  /// No description provided for @landingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Vahaolana feno ho an\'ny fiaraha-miasa, tompona fiara ary mpiasam-panjakana ho an\'ny fanaraha-maso mahomby sy mangarahara.'**
  String get landingWelcome;

  /// No description provided for @landingLogin.
  ///
  /// In en, this message translates to:
  /// **'Midira amin\'ny sehatra'**
  String get landingLogin;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Vahaolana ho an\'ny mpandray anjara tsirairay'**
  String get featuresTitle;

  /// No description provided for @feature1Title.
  ///
  /// In en, this message translates to:
  /// **'Fitantanana Tsotra ho an\'ny Fiaraha-miasa'**
  String get feature1Title;

  /// No description provided for @feature1Desc.
  ///
  /// In en, this message translates to:
  /// **'Araho ny fiaranao, tantano ny mpikambana, ary hatsarao ny asanao isan\'andro avy amin\'ny sehatra tokana.'**
  String get feature1Desc;

  /// No description provided for @feature2Title.
  ///
  /// In en, this message translates to:
  /// **'Fanarahamaso ho an\'ny Kaominina'**
  String get feature2Title;

  /// No description provided for @feature2Desc.
  ///
  /// In en, this message translates to:
  /// **'Mahazoa angona azo itokisana, fehezo ny fahazoan-dalana ary antoka ny fanarahana ny fitsipika ho an\'ny fitaterana azo antoka.'**
  String get feature2Desc;

  /// No description provided for @feature3Title.
  ///
  /// In en, this message translates to:
  /// **'Fitaovana ho an\'ny Mpiasam-panjakana sy Tompona Fiara'**
  String get feature3Title;

  /// No description provided for @feature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Atsaharo ny fanangonana fandoavam-bola, tantano ny toeram-piantsonana ary ampiaraho ny fifandraisana eo amin\'ireo mpandray anjara rehetra ao amin\'ny sehatra.'**
  String get feature3Desc;

  /// No description provided for @seeMap.
  ///
  /// In en, this message translates to:
  /// **'Hijery ny sarintany'**
  String get seeMap;

  /// No description provided for @feature4Title.
  ///
  /// In en, this message translates to:
  /// **'Sarintany Mifanentana Amin\'ny Fotoana Marina'**
  String get feature4Title;

  /// No description provided for @feature4Desc.
  ///
  /// In en, this message translates to:
  /// **'Jereo ny lalana, fantaro ny fiara, ary araho ny fifamoivoizana mivantana amin\'ny sarintany mora ampiasaina.'**
  String get feature4Desc;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Tongasoa'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Midira ao amin’ny sehatrao momba ny fivezivezena'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Adiresy mailaka'**
  String get emailLabel;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Ampidiro azafady ny mailakao'**
  String get emailValidation;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Teny miafina'**
  String get passwordLabel;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Ampidiro azafady ny tenimiafinao'**
  String get passwordValidation;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Hiditra'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Tsy nahomby ny fidirana. Hamarino azafady ny mailaka na teny miafina nampidirinao.'**
  String get loginFailed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Hadisoana'**
  String get error;

  /// No description provided for @demoInfo.
  ///
  /// In en, this message translates to:
  /// **'Fomba fanehoana: afaka mampiasa adiresy mailaka sy tenimiafina rehetra ianao'**
  String get demoInfo;

  /// No description provided for @cooperativeSpace.
  ///
  /// In en, this message translates to:
  /// **'Sehatra ho an\'ny kaoperativa'**
  String get cooperativeSpace;

  /// No description provided for @cooperativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Tantano ny fikambananareo amin’ny fitaterana, araho ny fiara voasoratra anarana ary ampanjary ny asanareo.'**
  String get cooperativeDescription;

  /// No description provided for @cooperativeFeature1.
  ///
  /// In en, this message translates to:
  /// **'Fitantanana ny fiara voasoratra anarana'**
  String get cooperativeFeature1;

  /// No description provided for @cooperativeFeature2.
  ///
  /// In en, this message translates to:
  /// **'Tabilao famakafakana'**
  String get cooperativeFeature2;

  /// No description provided for @cooperativeFeature3.
  ///
  /// In en, this message translates to:
  /// **'Fanaraha-maso ny vola miditra'**
  String get cooperativeFeature3;

  /// No description provided for @cooperativeFeature4.
  ///
  /// In en, this message translates to:
  /// **'Fitantanana ny mpamily'**
  String get cooperativeFeature4;

  /// No description provided for @proprietaireSpace.
  ///
  /// In en, this message translates to:
  /// **'Sehatra ho an\'ny tompony fiara'**
  String get proprietaireSpace;

  /// No description provided for @proprietaireDescription.
  ///
  /// In en, this message translates to:
  /// **'Soraty anarana ny fiaranao, tantano ny fahazoan-dàlana ary araho ny satan’ny fangatahanao.'**
  String get proprietaireDescription;

  /// No description provided for @proprietaireFeature1.
  ///
  /// In en, this message translates to:
  /// **'Fisoratana anarana fiara'**
  String get proprietaireFeature1;

  /// No description provided for @proprietaireFeature2.
  ///
  /// In en, this message translates to:
  /// **'Fangatahana fahazoan-dàlana'**
  String get proprietaireFeature2;

  /// No description provided for @proprietaireFeature3.
  ///
  /// In en, this message translates to:
  /// **'Fanaraha-maso ny antontan-taratasy'**
  String get proprietaireFeature3;

  /// No description provided for @proprietaireFeature4.
  ///
  /// In en, this message translates to:
  /// **'Tantaran’ny fifanakalozana'**
  String get proprietaireFeature4;

  /// No description provided for @chauffeurSpace.
  ///
  /// In en, this message translates to:
  /// **'Sehatra mpamily'**
  String get chauffeurSpace;

  /// No description provided for @chauffeurDescription.
  ///
  /// In en, this message translates to:
  /// **'Midira amin’ny dianao, araho ny vola miditra ary tantano ny fahafahanao miasa.'**
  String get chauffeurDescription;

  /// No description provided for @chauffeurFeature1.
  ///
  /// In en, this message translates to:
  /// **'Fitantanana ny dia'**
  String get chauffeurFeature1;

  /// No description provided for @chauffeurFeature2.
  ///
  /// In en, this message translates to:
  /// **'Fanaraha-maso ny vola miditra'**
  String get chauffeurFeature2;

  /// No description provided for @chauffeurFeature3.
  ///
  /// In en, this message translates to:
  /// **'Tantaran’ny dia'**
  String get chauffeurFeature3;

  /// No description provided for @chauffeurFeature4.
  ///
  /// In en, this message translates to:
  /// **'Fitantanana ny fahafahana miasa'**
  String get chauffeurFeature4;

  /// No description provided for @projectBadge.
  ///
  /// In en, this message translates to:
  /// **'TETIKASA FITATERANA AN-TANÀNA'**
  String get projectBadge;

  /// No description provided for @mobiliteTitle.
  ///
  /// In en, this message translates to:
  /// **'FITATERANA AN-TANÀNA'**
  String get mobiliteTitle;

  /// No description provided for @mobiliteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sehatra nomerika ho an’ny fitaterana an-tanàna marani-tsaina'**
  String get mobiliteSubtitle;

  /// No description provided for @accessButton.
  ///
  /// In en, this message translates to:
  /// **'Hiditra'**
  String get accessButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
