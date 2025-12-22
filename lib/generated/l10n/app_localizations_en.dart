// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToAccessAccount => 'Sign in to access your account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinCommunity => 'Join the pharmacy rewards community';

  @override
  String get uploadProfilePicture => 'Upload Profile Picture';

  @override
  String get allFieldsRequired => '* All fields are required';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get yourPharmacy => 'Your Pharmacy';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get agreeToTerms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get iAccept => 'I accept ';

  @override
  String get byContinuingYouAgree => 'By continuing, you agree to ';

  @override
  String get termsAndPrivacy => 'Terms of Use and Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get selectYourPharmacy => 'Select your pharmacy';

  @override
  String get pleaseSelectPharmacy => 'Please select a pharmacy';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get passwordResetLinkSent => 'We\'ve sent a password reset link to:';

  @override
  String get passwordResetExpiration =>
      'Check your email and click the link to reset your password. The link will expire in 24 hours.';

  @override
  String get sendAgain => 'Send Again';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get accountPendingApproval => 'Account Pending Approval';

  @override
  String get accountPendingApprovalMessage =>
      'Your account has been created successfully and is waiting for an administrator to approve it. Please check back later.';

  @override
  String get logOut => 'Log Out';

  @override
  String get welcome => 'Welcome';

  @override
  String get totalPoints => 'TOTAL POINTS';

  @override
  String get currentBalance => 'current balance';

  @override
  String get points => 'Points';

  @override
  String get rank => 'RANK';

  @override
  String get badges => 'BADGES';

  @override
  String get challenges => 'CHALLENGES';

  @override
  String get goals => 'Goals';

  @override
  String get weeklyQuiz => 'Weekly Quiz';

  @override
  String get testYourKnowledge => 'Test your pharmaceutical knowledge';

  @override
  String get takeQuiz => 'Take Quiz';

  @override
  String get activeGoals => 'Active Goals';

  @override
  String get noActiveGoals => 'No active goals.';

  @override
  String get checkBackSoon => 'Check back soon for new goals!';

  @override
  String get complete => 'Complete';

  @override
  String get progressDetails => 'Progress Details';

  @override
  String get viewRules => 'View Rules';

  @override
  String get trackProgress => 'Track Progress';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get yourRank => 'YOUR RANK';

  @override
  String outOfEmployees(Object count) {
    return 'out of $count employees';
  }

  @override
  String get topPerformers => 'TOP PERFORMERS';

  @override
  String get allEmployees => 'ALL EMPLOYEES';

  @override
  String get myPersonalDetails => 'My personal details';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get rewardsAndRedeem => 'Rewards & Points Exchange';

  @override
  String allTimeRewardPoints(Object points) {
    return 'All time reward points earned: $points';
  }

  @override
  String get viewRewardPointsHistory => 'View reward points history';

  @override
  String get redeemYourPoints => 'Redeem my points';

  @override
  String get noRewardsAvailable => 'No rewards available';

  @override
  String get cancel => 'Cancel';

  @override
  String get redeem => 'Redeem';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get confirmDeletionMessage =>
      'Are you sure you want to delete this sale? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get yourPosition => 'Your Position';

  @override
  String get selectPosition => 'Select your position';

  @override
  String get pleaseSelectPosition => 'Please select your position';

  @override
  String get pharmacienTitulaire => 'Licensed Pharmacist';

  @override
  String get pharmacienAssistant => 'Assistant Pharmacist';

  @override
  String get preparateur => 'Pharmacy Technician';

  @override
  String get responsableParapharmacie => 'Parapharmacy Manager';

  @override
  String get scanBarcodeHere => 'Scan barcode here';

  @override
  String get scannedProduct => 'Scanned Product';

  @override
  String get productDetailsAppearHere => 'Product details will appear here.';

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get availableStock => 'Available Stock';

  @override
  String get quantity => 'Quantity';

  @override
  String get recommendedPrice => 'Recommended Price';

  @override
  String get usageTips => 'Usage Tips';

  @override
  String get protocol => 'Products to Suggest With';

  @override
  String get activeCampaigns => 'Active Campaigns';

  @override
  String get relatedGoals => 'Related Goals';

  @override
  String get recommendedWith => 'Products to Suggest With';

  @override
  String get confirmSale => 'Confirm Sale';

  @override
  String get updateSale => 'Update Sale';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get description => 'Description';

  @override
  String get composition => 'Composition';

  @override
  String get salesHistory => 'Sales History';

  @override
  String get noSalesRecorded => 'No sales recorded in this period.';

  @override
  String get start => 'Start:';

  @override
  String get end => 'End:';

  @override
  String get select => 'Select';

  @override
  String get clear => 'Clear';

  @override
  String get filter => 'Filter';

  @override
  String get navHome => 'Home';

  @override
  String get navChallenges => 'Formations';

  @override
  String get navLeaderboard => 'Actualités';

  @override
  String get navHistory => 'History';

  @override
  String get welcomeMessage => 'Welcome!';

  @override
  String welcomeUser(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get today => 'Today';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get availableQuizzes => 'Available Quizzes';

  @override
  String get noQuizzesAvailable => 'No Quizzes Available';

  @override
  String get questions => 'Questions';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get viewAll => 'View All';

  @override
  String get goalDetails => 'Goal Details';

  @override
  String get eligibilityCriteria => 'Eligibility Criteria';

  @override
  String get eligibleProducts => 'Eligible Products';

  @override
  String get eligibleBrands => 'Eligible Brands';

  @override
  String get eligibleCategories => 'Eligible Categories';

  @override
  String get eligibleZones => 'Eligible Zones';

  @override
  String get eligibleClientCategories => 'Eligible Client Categories';

  @override
  String get eligiblePharmacies => 'Eligible Pharmacies';

  @override
  String get noSpecificCriteria => 'This goal applies to all sales.';

  @override
  String activeGoalsCount(int count) {
    return 'You have $count active goals';
  }

  @override
  String endsInDays(int count) {
    return 'Ends in ${count}d';
  }

  @override
  String endsInHours(int count) {
    return 'Ends in ${count}h';
  }

  @override
  String endsInMinutes(int count) {
    return 'Ends in ${count}m';
  }

  @override
  String get endingSoon => 'Ending soon';

  @override
  String stockAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '$count piece',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'All-Time';

  @override
  String get yearlyRank => 'Yearly Rank';

  @override
  String get activeGoal => 'Active Goal';

  @override
  String get latestBadge => 'Latest Badge';

  @override
  String get noBadgesEarned => 'No badges earned yet.';

  @override
  String availablePoints(int points) {
    return 'Available: $points pts';
  }

  @override
  String pendingPoints(int points) {
    return '$points pts pending approval';
  }

  @override
  String get pluxeeCredits => 'Rewards & Points Exchange';

  @override
  String get redeemPluxeeCredits => 'Redeem Pluxee Credits';

  @override
  String get howItWorks => 'Redeem My Points – How Does It Work?';

  @override
  String get choosePointsToConvert =>
      'Choose the number of points you wish to convert';

  @override
  String get submitForReview => 'Validate your request with one click';

  @override
  String get onceApproved =>
      'We process your request and get back to you with an answer within 72 business hours';

  @override
  String conversionRate(int points) {
    return '$points points = 1 Pluxee credit';
  }

  @override
  String get redeemPointsNow => 'Redeem your points';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get redemptionHistory => 'Redemption History';

  @override
  String get viewRedemptionHistory => 'View Redemption History';

  @override
  String get noRedemptionHistory => 'No Redemption History';

  @override
  String get noRedemptionHistoryMessage =>
      'You have not made any redemption requests yet.';

  @override
  String get pointsToRedeem => 'Points to Redeem';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get youWillReceive => 'You will receive:';

  @override
  String pluxeeCreditsAmount(String amount) {
    return '$amount Pluxee Credits';
  }

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get requestSubmittedSuccess =>
      'Request submitted successfully! It will be reviewed by an admin.';

  @override
  String get requestedDate => 'Requested';

  @override
  String get processedDate => 'Processed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get tapToViewReason => 'Tap to view rejection reason';

  @override
  String get rejectionReason => 'Rejection Reason';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get close => 'Close';

  @override
  String pointsPendingApproval(double points) {
    final intl.NumberFormat pointsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pointsString = pointsNumberFormat.format(points);

    return '$pointsString points pending approval';
  }

  @override
  String get productNotAvailable => 'Product Not Available';

  @override
  String get productNotAvailableMessage =>
      'This product is not available at the moment. Please try again later.';

  @override
  String get goBack => 'Go Back';

  @override
  String get pointsAccumulatedToDate => 'Points accumulated\nto date';

  @override
  String get currentPointsBalance => 'Usable Points\nBalance';

  @override
  String get rankingOn => 'Classement sur xx inscrits';

  @override
  String outOf(int count) {
    return 'out of $count registered';
  }

  @override
  String get performanceTracking => 'Suivi des\nperformances';

  @override
  String get objectives => 'Objectifs';

  @override
  String get lastBadge => 'Dernier badge';

  @override
  String get nationalRanking => 'Classement national';

  @override
  String rankOnMychallenge(String rank, int total) {
    return '${rank}e sur $total inscrits sur mychallenge';
  }

  @override
  String get nationalPodium => 'Le podium national';

  @override
  String get myNationalPosition => 'Ma position sur le classement national';

  @override
  String get badgeEarned => 'Badge Earned!';

  @override
  String awardedOn(String date) {
    return 'Awarded on $date';
  }

  @override
  String get progress => 'Progress';

  @override
  String get badgesLeft => 'Badges Left';

  @override
  String get target => 'Target';

  @override
  String get eventPeriod => 'Event Period';

  @override
  String get to => 'to';

  @override
  String get metric => 'Metric';

  @override
  String get scope => 'Scope';

  @override
  String get brands => 'Brands';

  @override
  String get categories => 'Categories';

  @override
  String get products => 'Products';

  @override
  String specificProducts(int count) {
    return '$count specific products';
  }

  @override
  String get loyaltyPoints => 'Cumulative Points';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get quantitySold => 'Quantity Sold';

  @override
  String get badgeRewardPoints => 'Points Rewarded';

  @override
  String get showLess => 'Show Less';

  @override
  String get noBadgesAvailable => 'No badges available.';

  @override
  String get noBadgesInCategory => 'No badges in this category yet.';
}
