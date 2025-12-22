// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToAccessAccount =>
      'Connectez-vous pour accéder à votre compte';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinCommunity =>
      'Rejoignez la communauté des récompenses de la pharmacie';

  @override
  String get uploadProfilePicture => 'Télécharger une photo de profil';

  @override
  String get allFieldsRequired => '* Tous les champs sont obligatoires';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get yourPharmacy => 'Votre pharmacie';

  @override
  String get confirmPassword => 'Confirmez le mot de passe';

  @override
  String get agreeToTerms =>
      'J\'accepte les conditions d\'utilisation et la politique de confidentialité';

  @override
  String get iAccept => 'J\'accepte ';

  @override
  String get byContinuingYouAgree => 'En continuant, vous acceptez ';

  @override
  String get termsAndPrivacy =>
      'les conditions d\'utilisation et la politique de confidentialité';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte? ';

  @override
  String get selectYourPharmacy => 'Sélectionnez votre pharmacie';

  @override
  String get pleaseSelectPharmacy => 'Veuillez sélectionner une pharmacie';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordInstructions =>
      'Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get checkYourEmail => 'Vérifiez votre e-mail';

  @override
  String get passwordResetLinkSent =>
      'Nous avons envoyé un lien de réinitialisation de mot de passe à :';

  @override
  String get passwordResetExpiration =>
      'Vérifiez votre e-mail et cliquez sur le lien pour réinitialiser votre mot de passe. Le lien expirera dans 24 heures.';

  @override
  String get sendAgain => 'Renvoyer';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get accountPendingApproval => 'Compte en attente d\'approbation';

  @override
  String get accountPendingApprovalMessage =>
      'Votre compte a été créé avec succès et est en attente d\'approbation par un administrateur. Veuillez revenir plus tard.';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get totalPoints => 'POINTS TOTAUX';

  @override
  String get currentBalance => 'solde actuel';

  @override
  String get points => 'Points';

  @override
  String get rank => 'RANG';

  @override
  String get badges => 'BADGES';

  @override
  String get challenges => 'DÉFIS';

  @override
  String get goals => 'Objectifs';

  @override
  String get weeklyQuiz => 'Quiz de la semaine';

  @override
  String get testYourKnowledge => 'Testez vos connaissances pharmaceutiques';

  @override
  String get takeQuiz => 'Faire le quiz';

  @override
  String get activeGoals => 'Objectifs actifs';

  @override
  String get noActiveGoals => 'Aucun objectif actif.';

  @override
  String get checkBackSoon => 'Revenez bientôt pour de nouveaux objectifs !';

  @override
  String get complete => 'Terminé';

  @override
  String get progressDetails => 'Détails de la progression';

  @override
  String get viewRules => 'Voir les règles';

  @override
  String get trackProgress => 'Suivre la progression';

  @override
  String get leaderboard => 'Classement';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdo';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get yourRank => 'VOTRE RANG';

  @override
  String outOfEmployees(Object count) {
    return 'sur $count employés';
  }

  @override
  String get topPerformers => 'MEILLEURS PERFORMANTS';

  @override
  String get allEmployees => 'TOUS LES EMPLOYÉS';

  @override
  String get myPersonalDetails => 'Mes informations personnelles';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phone => 'Téléphone';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get disconnect => 'Se déconnecter';

  @override
  String get rewardsAndRedeem => 'Récompenses & échanges de points';

  @override
  String allTimeRewardPoints(Object points) {
    return 'Total des points de récompense gagnés : $points';
  }

  @override
  String get viewRewardPointsHistory =>
      'Voir l\'historique des points de récompense';

  @override
  String get redeemYourPoints => 'Échanger mes points';

  @override
  String get noRewardsAvailable => 'Aucune récompense disponible';

  @override
  String get cancel => 'Annuler';

  @override
  String get redeem => 'Échanger';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get confirmDeletionMessage =>
      'Êtes-vous sûr de vouloir supprimer cette vente ? Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get yourPosition => 'Votre position';

  @override
  String get selectPosition => 'Sélectionnez votre position';

  @override
  String get pleaseSelectPosition => 'Veuillez sélectionner votre position';

  @override
  String get pharmacienTitulaire => 'Pharmacien titulaire';

  @override
  String get pharmacienAssistant => 'Pharmacien assistant';

  @override
  String get preparateur => 'Préparateur';

  @override
  String get responsableParapharmacie => 'Responsable parapharmacie';

  @override
  String get scanBarcodeHere => 'Scannez le code-barres ici';

  @override
  String get scannedProduct => 'Produit scanné';

  @override
  String get productDetailsAppearHere =>
      'Les détails du produit apparaîtront ici.';

  @override
  String get saleDetails => 'Détails de la vente';

  @override
  String get availableStock => 'Stock disponible';

  @override
  String get quantity => 'Quantité';

  @override
  String get recommendedPrice => 'Prix recommandé';

  @override
  String get usageTips => 'Conseil d\'utilisation';

  @override
  String get protocol => 'Produits à proposer avec';

  @override
  String get activeCampaigns => 'Campagnes actives';

  @override
  String get relatedGoals => 'Objectifs associés';

  @override
  String get recommendedWith => 'Produits à proposer avec';

  @override
  String get confirmSale => 'Confirmer la vente';

  @override
  String get updateSale => 'Mettre à jour la vente';

  @override
  String get outOfStock => 'En rupture de stock';

  @override
  String get description => 'Description';

  @override
  String get composition => 'Composition';

  @override
  String get salesHistory => 'Historique des ventes';

  @override
  String get noSalesRecorded => 'Aucune vente enregistrée pour cette période.';

  @override
  String get start => 'Début :';

  @override
  String get end => 'Fin :';

  @override
  String get select => 'Sélectionner';

  @override
  String get clear => 'Effacer';

  @override
  String get filter => 'Filtrer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navChallenges => 'Formations';

  @override
  String get navLeaderboard => 'Actualités';

  @override
  String get navHistory => 'Historique';

  @override
  String get welcomeMessage => 'Bienvenue !';

  @override
  String welcomeUser(Object name) {
    return 'Bienvenue, $name !';
  }

  @override
  String get today => 'Auj.';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get availableQuizzes => 'Quiz disponibles';

  @override
  String get noQuizzesAvailable => 'Aucun quiz disponible';

  @override
  String get questions => 'Questions';

  @override
  String get startQuiz => 'Commencer le quiz';

  @override
  String get quizzes => 'Quiz';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get goalDetails => 'Détails de l\'objectif';

  @override
  String get eligibilityCriteria => 'Critères d\'éligibilité';

  @override
  String get eligibleProducts => 'Produits éligibles';

  @override
  String get eligibleBrands => 'Marques éligibles';

  @override
  String get eligibleCategories => 'Catégories éligibles';

  @override
  String get eligibleZones => 'Zones éligibles';

  @override
  String get eligibleClientCategories => 'Catégories de clients éligibles';

  @override
  String get eligiblePharmacies => 'Pharmacies éligibles';

  @override
  String get noSpecificCriteria =>
      'Cet objectif s\'applique à toutes les ventes.';

  @override
  String activeGoalsCount(int count) {
    return 'Vous avez $count objectifs actifs';
  }

  @override
  String endsInDays(int count) {
    return 'Termine dans ${count}j';
  }

  @override
  String endsInHours(int count) {
    return 'Termine dans ${count}h';
  }

  @override
  String endsInMinutes(int count) {
    return 'Termine dans ${count}m';
  }

  @override
  String get endingSoon => 'Se termine bientôt';

  @override
  String stockAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '$count pièce',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Depuis toujours';

  @override
  String get yearlyRank => 'Rang Annuel';

  @override
  String get activeGoal => 'Objectif Actif';

  @override
  String get latestBadge => 'Dernier Badge';

  @override
  String get noBadgesEarned => 'Aucun badge gagné.';

  @override
  String availablePoints(int points) {
    return 'Disponible: $points pts';
  }

  @override
  String pendingPoints(int points) {
    return '$points pts en attente d\'approbation';
  }

  @override
  String get pluxeeCredits => 'Récompenses & échanges de points';

  @override
  String get redeemPluxeeCredits => 'Échanger des crédits Pluxee';

  @override
  String get howItWorks => 'Échanger mes points – Comment ça marche ?';

  @override
  String get choosePointsToConvert =>
      'Choisissez le nombre de points que vous souhaitez convertir';

  @override
  String get submitForReview => 'Validez votre demande en un clic';

  @override
  String get onceApproved =>
      'Nous traitons votre demande et vous revenons avec une réponse dans les 72h ouvrées';

  @override
  String conversionRate(int points) {
    return '$points points = 1 crédit Pluxee';
  }

  @override
  String get redeemPointsNow => 'Échanger vos points';

  @override
  String get pendingRequests => 'Demandes en attente';

  @override
  String get redemptionHistory => 'Historique des échanges';

  @override
  String get viewRedemptionHistory => 'Voir l\'historique des échanges';

  @override
  String get noRedemptionHistory => 'Aucun historique d\'échange';

  @override
  String get noRedemptionHistoryMessage =>
      'Vous n\'avez pas encore fait de demande d\'échange.';

  @override
  String get pointsToRedeem => 'Points à échanger';

  @override
  String get enterAmount => 'Entrez le montant';

  @override
  String get youWillReceive => 'Vous recevrez:';

  @override
  String pluxeeCreditsAmount(String amount) {
    return '$amount crédits Pluxee';
  }

  @override
  String get submitRequest => 'Soumettre la demande';

  @override
  String get requestSubmittedSuccess =>
      'Demande soumise avec succès ! Elle sera examinée par un administrateur.';

  @override
  String get requestedDate => 'Demandé';

  @override
  String get processedDate => 'Traité';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusApproved => 'Approuvé';

  @override
  String get statusRejected => 'Rejeté';

  @override
  String get tapToViewReason => 'Appuyez pour voir la raison du rejet';

  @override
  String get rejectionReason => 'Raison du rejet';

  @override
  String get noReasonProvided => 'Aucune raison fournie';

  @override
  String get close => 'Fermer';

  @override
  String pointsPendingApproval(double points) {
    final intl.NumberFormat pointsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pointsString = pointsNumberFormat.format(points);

    return '$pointsString points en attente d\'approbation';
  }

  @override
  String get productNotAvailable => 'Produit non disponible';

  @override
  String get productNotAvailableMessage =>
      'Ce produit n\'est pas disponible pour le moment. Veuillez réessayer plus tard.';

  @override
  String get goBack => 'Retour';

  @override
  String get pointsAccumulatedToDate => 'Points cumulés\nà ce jour';

  @override
  String get currentPointsBalance => 'Solde de points\nutilisables';

  @override
  String get rankingOn => 'Classement sur xx inscrits';

  @override
  String outOf(int count) {
    return 'sur $count inscrits';
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
  String get badgeEarned => 'Badge gagné !';

  @override
  String awardedOn(String date) {
    return 'Attribué le $date';
  }

  @override
  String get progress => 'Progression';

  @override
  String get badgesLeft => 'Badges restants';

  @override
  String get target => 'Cible';

  @override
  String get eventPeriod => 'Période de l\'événement';

  @override
  String get to => 'à';

  @override
  String get metric => 'Métrique';

  @override
  String get scope => 'Portée';

  @override
  String get brands => 'Marques';

  @override
  String get categories => 'Catégories';

  @override
  String get products => 'Produits';

  @override
  String specificProducts(int count) {
    return '$count produits spécifiques';
  }

  @override
  String get loyaltyPoints => 'Points cumulés';

  @override
  String get totalRevenue => 'Revenu total';

  @override
  String get quantitySold => 'Quantité vendue';

  @override
  String get badgeRewardPoints => 'Points accordés';

  @override
  String get showLess => 'Voir moins';

  @override
  String get noBadgesAvailable => 'Aucun badge disponible.';

  @override
  String get noBadgesInCategory =>
      'Aucun badge dans cette catégorie pour le moment.';
}
