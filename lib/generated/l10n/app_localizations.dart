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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToAccessAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get signInToAccessAccount;

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

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the pharmacy rewards community'**
  String get joinCommunity;

  /// No description provided for @uploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Picture'**
  String get uploadProfilePicture;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'* All fields are required'**
  String get allFieldsRequired;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @yourPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Your Pharmacy'**
  String get yourPharmacy;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @iAccept.
  ///
  /// In en, this message translates to:
  /// **'I accept '**
  String get iAccept;

  /// No description provided for @byContinuingYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to '**
  String get byContinuingYouAgree;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @selectYourPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Select your pharmacy'**
  String get selectYourPharmacy;

  /// No description provided for @pleaseSelectPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Please select a pharmacy'**
  String get pleaseSelectPharmacy;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to:'**
  String get passwordResetLinkSent;

  /// No description provided for @passwordResetExpiration.
  ///
  /// In en, this message translates to:
  /// **'Check your email and click the link to reset your password. The link will expire in 24 hours.'**
  String get passwordResetExpiration;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send Again'**
  String get sendAgain;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @accountPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Account Pending Approval'**
  String get accountPendingApproval;

  /// No description provided for @accountPendingApprovalMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully and is waiting for an administrator to approve it. Please check back later.'**
  String get accountPendingApprovalMessage;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'TOTAL POINTS'**
  String get totalPoints;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'current balance'**
  String get currentBalance;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get rank;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'BADGES'**
  String get badges;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES'**
  String get challenges;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @weeklyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Weekly Quiz'**
  String get weeklyQuiz;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test your pharmaceutical knowledge'**
  String get testYourKnowledge;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get activeGoals;

  /// No description provided for @noActiveGoals.
  ///
  /// In en, this message translates to:
  /// **'No active goals.'**
  String get noActiveGoals;

  /// No description provided for @checkBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new goals!'**
  String get checkBackSoon;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @progressDetails.
  ///
  /// In en, this message translates to:
  /// **'Progress Details'**
  String get progressDetails;

  /// No description provided for @viewRules.
  ///
  /// In en, this message translates to:
  /// **'View Rules'**
  String get viewRules;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get trackProgress;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'YOUR RANK'**
  String get yourRank;

  /// No description provided for @outOfEmployees.
  ///
  /// In en, this message translates to:
  /// **'out of {count} employees'**
  String outOfEmployees(Object count);

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'TOP PERFORMERS'**
  String get topPerformers;

  /// No description provided for @allEmployees.
  ///
  /// In en, this message translates to:
  /// **'ALL EMPLOYEES'**
  String get allEmployees;

  /// No description provided for @myPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'My personal details'**
  String get myPersonalDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @rewardsAndRedeem.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Points Exchange'**
  String get rewardsAndRedeem;

  /// No description provided for @allTimeRewardPoints.
  ///
  /// In en, this message translates to:
  /// **'All time reward points earned: {points}'**
  String allTimeRewardPoints(Object points);

  /// No description provided for @viewRewardPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'View reward points history'**
  String get viewRewardPointsHistory;

  /// No description provided for @redeemYourPoints.
  ///
  /// In en, this message translates to:
  /// **'Redeem my points'**
  String get redeemYourPoints;

  /// No description provided for @noRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rewards available'**
  String get noRewardsAvailable;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeletionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sale? This action cannot be undone.'**
  String get confirmDeletionMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your Position'**
  String get yourPosition;

  /// No description provided for @selectPosition.
  ///
  /// In en, this message translates to:
  /// **'Select your position'**
  String get selectPosition;

  /// No description provided for @pleaseSelectPosition.
  ///
  /// In en, this message translates to:
  /// **'Please select your position'**
  String get pleaseSelectPosition;

  /// No description provided for @pharmacienTitulaire.
  ///
  /// In en, this message translates to:
  /// **'Licensed Pharmacist'**
  String get pharmacienTitulaire;

  /// No description provided for @pharmacienAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant Pharmacist'**
  String get pharmacienAssistant;

  /// No description provided for @preparateur.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Technician'**
  String get preparateur;

  /// No description provided for @responsableParapharmacie.
  ///
  /// In en, this message translates to:
  /// **'Parapharmacy Manager'**
  String get responsableParapharmacie;

  /// No description provided for @scanBarcodeHere.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode here'**
  String get scanBarcodeHere;

  /// No description provided for @scannedProduct.
  ///
  /// In en, this message translates to:
  /// **'Scanned Product'**
  String get scannedProduct;

  /// No description provided for @productDetailsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Product details will appear here.'**
  String get productDetailsAppearHere;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available Stock'**
  String get availableStock;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @recommendedPrice.
  ///
  /// In en, this message translates to:
  /// **'Recommended Price'**
  String get recommendedPrice;

  /// No description provided for @usageTips.
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get usageTips;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Products to Suggest With'**
  String get protocol;

  /// No description provided for @activeCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Active Campaigns'**
  String get activeCampaigns;

  /// No description provided for @relatedGoals.
  ///
  /// In en, this message translates to:
  /// **'Related Goals'**
  String get relatedGoals;

  /// No description provided for @recommendedWith.
  ///
  /// In en, this message translates to:
  /// **'Products to Suggest With'**
  String get recommendedWith;

  /// No description provided for @confirmSale.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sale'**
  String get confirmSale;

  /// No description provided for @updateSale.
  ///
  /// In en, this message translates to:
  /// **'Update Sale'**
  String get updateSale;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @composition.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get composition;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get salesHistory;

  /// No description provided for @noSalesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded in this period.'**
  String get noSalesRecorded;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start:'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End:'**
  String get end;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChallenges.
  ///
  /// In en, this message translates to:
  /// **'Formations'**
  String get navChallenges;

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Actualités'**
  String get navLeaderboard;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeMessage;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(Object name);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @availableQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Available Quizzes'**
  String get availableQuizzes;

  /// No description provided for @noQuizzesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Quizzes Available'**
  String get noQuizzesAvailable;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @goalDetails.
  ///
  /// In en, this message translates to:
  /// **'Goal Details'**
  String get goalDetails;

  /// No description provided for @eligibilityCriteria.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Criteria'**
  String get eligibilityCriteria;

  /// No description provided for @eligibleProducts.
  ///
  /// In en, this message translates to:
  /// **'Eligible Products'**
  String get eligibleProducts;

  /// No description provided for @eligibleBrands.
  ///
  /// In en, this message translates to:
  /// **'Eligible Brands'**
  String get eligibleBrands;

  /// No description provided for @eligibleCategories.
  ///
  /// In en, this message translates to:
  /// **'Eligible Categories'**
  String get eligibleCategories;

  /// No description provided for @eligibleZones.
  ///
  /// In en, this message translates to:
  /// **'Eligible Zones'**
  String get eligibleZones;

  /// No description provided for @eligibleClientCategories.
  ///
  /// In en, this message translates to:
  /// **'Eligible Client Categories'**
  String get eligibleClientCategories;

  /// No description provided for @eligiblePharmacies.
  ///
  /// In en, this message translates to:
  /// **'Eligible Pharmacies'**
  String get eligiblePharmacies;

  /// No description provided for @noSpecificCriteria.
  ///
  /// In en, this message translates to:
  /// **'This goal applies to all sales.'**
  String get noSpecificCriteria;

  /// The number of active goals displayed in the header
  ///
  /// In en, this message translates to:
  /// **'You have {count} active goals'**
  String activeGoalsCount(int count);

  /// No description provided for @endsInDays.
  ///
  /// In en, this message translates to:
  /// **'Ends in {count}d'**
  String endsInDays(int count);

  /// No description provided for @endsInHours.
  ///
  /// In en, this message translates to:
  /// **'Ends in {count}h'**
  String endsInHours(int count);

  /// No description provided for @endsInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Ends in {count}m'**
  String endsInMinutes(int count);

  /// No description provided for @endingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get endingSoon;

  /// The amount of stock available
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{{count} piece} other{{count} pieces}}'**
  String stockAmount(int count);

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All-Time'**
  String get allTime;

  /// No description provided for @yearlyRank.
  ///
  /// In en, this message translates to:
  /// **'Yearly Rank'**
  String get yearlyRank;

  /// No description provided for @activeGoal.
  ///
  /// In en, this message translates to:
  /// **'Active Goal'**
  String get activeGoal;

  /// No description provided for @latestBadge.
  ///
  /// In en, this message translates to:
  /// **'Latest Badge'**
  String get latestBadge;

  /// No description provided for @noBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'No badges earned yet.'**
  String get noBadgesEarned;

  /// Available points after pending deductions
  ///
  /// In en, this message translates to:
  /// **'Available: {points} pts'**
  String availablePoints(int points);

  /// Points pending approval
  ///
  /// In en, this message translates to:
  /// **'{points} pts pending approval'**
  String pendingPoints(int points);

  /// No description provided for @pluxeeCredits.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Points Exchange'**
  String get pluxeeCredits;

  /// No description provided for @redeemPluxeeCredits.
  ///
  /// In en, this message translates to:
  /// **'Redeem Pluxee Credits'**
  String get redeemPluxeeCredits;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'Redeem My Points – How Does It Work?'**
  String get howItWorks;

  /// No description provided for @choosePointsToConvert.
  ///
  /// In en, this message translates to:
  /// **'Choose the number of points you wish to convert'**
  String get choosePointsToConvert;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Validate your request with one click'**
  String get submitForReview;

  /// No description provided for @onceApproved.
  ///
  /// In en, this message translates to:
  /// **'We process your request and get back to you with an answer within 72 business hours'**
  String get onceApproved;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'{points} points = 1 Pluxee credit'**
  String conversionRate(int points);

  /// No description provided for @redeemPointsNow.
  ///
  /// In en, this message translates to:
  /// **'Redeem your points'**
  String get redeemPointsNow;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @redemptionHistory.
  ///
  /// In en, this message translates to:
  /// **'Redemption History'**
  String get redemptionHistory;

  /// No description provided for @viewRedemptionHistory.
  ///
  /// In en, this message translates to:
  /// **'View Redemption History'**
  String get viewRedemptionHistory;

  /// No description provided for @noRedemptionHistory.
  ///
  /// In en, this message translates to:
  /// **'No Redemption History'**
  String get noRedemptionHistory;

  /// No description provided for @noRedemptionHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'You have not made any redemption requests yet.'**
  String get noRedemptionHistoryMessage;

  /// No description provided for @pointsToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Points to Redeem'**
  String get pointsToRedeem;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @youWillReceive.
  ///
  /// In en, this message translates to:
  /// **'You will receive:'**
  String get youWillReceive;

  /// No description provided for @pluxeeCreditsAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} Pluxee Credits'**
  String pluxeeCreditsAmount(String amount);

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @requestSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully! It will be reviewed by an admin.'**
  String get requestSubmittedSuccess;

  /// No description provided for @requestedDate.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requestedDate;

  /// No description provided for @processedDate.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processedDate;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @tapToViewReason.
  ///
  /// In en, this message translates to:
  /// **'Tap to view rejection reason'**
  String get tapToViewReason;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @noReasonProvided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get noReasonProvided;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @pointsPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'{points} points pending approval'**
  String pointsPendingApproval(double points);

  /// No description provided for @productNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product Not Available'**
  String get productNotAvailable;

  /// No description provided for @productNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This product is not available at the moment. Please try again later.'**
  String get productNotAvailableMessage;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @pointsAccumulatedToDate.
  ///
  /// In en, this message translates to:
  /// **'Points accumulated\nto date'**
  String get pointsAccumulatedToDate;

  /// No description provided for @currentPointsBalance.
  ///
  /// In en, this message translates to:
  /// **'Usable Points\nBalance'**
  String get currentPointsBalance;

  /// No description provided for @rankingOn.
  ///
  /// In en, this message translates to:
  /// **'Classement sur xx inscrits'**
  String get rankingOn;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of {count} registered'**
  String outOf(int count);

  /// No description provided for @performanceTracking.
  ///
  /// In en, this message translates to:
  /// **'Suivi des\nperformances'**
  String get performanceTracking;

  /// No description provided for @objectives.
  ///
  /// In en, this message translates to:
  /// **'Objectifs'**
  String get objectives;

  /// No description provided for @lastBadge.
  ///
  /// In en, this message translates to:
  /// **'Dernier badge'**
  String get lastBadge;

  /// No description provided for @nationalRanking.
  ///
  /// In en, this message translates to:
  /// **'Classement national'**
  String get nationalRanking;

  /// No description provided for @rankOnMychallenge.
  ///
  /// In en, this message translates to:
  /// **'{rank}e sur {total} inscrits sur mychallenge'**
  String rankOnMychallenge(String rank, int total);

  /// No description provided for @nationalPodium.
  ///
  /// In en, this message translates to:
  /// **'Le podium national'**
  String get nationalPodium;

  /// No description provided for @myNationalPosition.
  ///
  /// In en, this message translates to:
  /// **'Ma position sur le classement national'**
  String get myNationalPosition;

  /// No description provided for @badgeEarned.
  ///
  /// In en, this message translates to:
  /// **'Badge Earned!'**
  String get badgeEarned;

  /// No description provided for @awardedOn.
  ///
  /// In en, this message translates to:
  /// **'Awarded on {date}'**
  String awardedOn(String date);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @badgesLeft.
  ///
  /// In en, this message translates to:
  /// **'Badges Left'**
  String get badgesLeft;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @eventPeriod.
  ///
  /// In en, this message translates to:
  /// **'Event Period'**
  String get eventPeriod;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @specificProducts.
  ///
  /// In en, this message translates to:
  /// **'{count} specific products'**
  String specificProducts(int count);

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Cumulative Points'**
  String get loyaltyPoints;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Quantity Sold'**
  String get quantitySold;

  /// No description provided for @badgeRewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Points Rewarded'**
  String get badgeRewardPoints;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @noBadgesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No badges available.'**
  String get noBadgesAvailable;

  /// No description provided for @noBadgesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No badges in this category yet.'**
  String get noBadgesInCategory;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
