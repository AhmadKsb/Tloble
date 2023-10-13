import 'package:firebase_auth/firebase_auth.dart';
import 'package:wkbeast/models/driver.dart';

class HomeScreenController {
  final Map<String, dynamic> ratesAppInfoSnapshot;
  final Map<String, dynamic> appInfoSnapshot;
  final Map<String, dynamic> sellRatesAppInfoSnapshot;

  HomeScreenController(
    this.ratesAppInfoSnapshot,
    this.appInfoSnapshot,
    this.sellRatesAppInfoSnapshot,
  ) {
    fillFieldsFromData();
  }

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  num _newsUpdateDuration,
      _loadUpdateDuration,
      _fiftyToHundred,
      _hundredToThousand,
      _thousandToThreeThousand,
      _threeThousandToFiveThousand,
      _fiveThousandToTenThousand,
      _smallAmountsLimit,
      _addToAhmadSalary,
      _myProfitFromSignals,
      _totalProfit,
      _totalProfitFromSignals,
      _myPercentageFromSignals,
      _coinsToJoinTelegram,
      _sellFiftyToHundred,
      _sellHundredToThousand,
      _sellThousandToThreeThousand,
      _sellThreeThousandToFiveThousand,
      _sellFiveThousandToTenThousand,
      _signalsSubscriptionPrice,
      minimumOrder;

  String _weekdayOpeningHours,
      _lastResetDate,
      _feedbackSuccessMessage,
      _feedbackSuccessMessageAR,
      _signalsGroupWalletAddress,
      _contactUsNumber,
      _mainCurrency,
      submissionText,
      submissionTextAR,
      _detailsAboutYourLocationHint,
      _weekdayClosingHours,
      _weekendOpeningHours,
      _weekendClosingHours,
      _coachMarkText,
      _coachMarkTextAR,
      _coachMarkCampaign,
      _miningDisabledMessage,
      _miningDisabledMessageAR,
      _rewardsDisabledMessage,
      _rewardsDisabledMessageAR,
      _minableItemSearchBarHintText,
      _minableItemSearchBarHintTextAR,
      _profitabilityHintText,
      _miningInformationDialogText,
      _miningInformationDialogTextAR,
      _rewardInformationDialogText,
      _rewardInformationDialogTextAR,
      _minableCoinsHintText,
      _priceHintText,
      _powerConsumptionHintText,
      _salesNumber,
      _salesEmail,
      _signalsSupportNumber,
      _supportNumber,
      _supportEmail,
      _website,
      _github,
      _linkedIn,
      _twitter,
      _instagram,
      _facebook,
      _telegram,
      _tiktok;

  bool _isSundayOff,
      _showSendUsYourFeedbacks,
      _showChangeLanguage,
      _showTelegramDialog,
      _showCryptoCurrencyNews,
      _shouldLoadAgainAfterTimer,
      _checkForOpeningHours,
      _showSellRate,
      _checkForRoot,
      _checkForMinimumOrder,
      _openMiningItemDetailsScreen,
      _isHoliday,
      _showCoachMark,
      showCustomError,
      _forceUpdate,
      _showMinableItemSearchBar,
      _isAdmin = false,
      _feedbackReceiver = false,
      _scrollToEndInTelegramScreen = false,
      _showLargeOrders = false,
      _showMisc = false,
      _showAddToAhmadSalary = false,
      _allowedToCheckCustomersBalance = false,
      _showSortingButton = true,
      _isBanned = false,
      _isMiningEnabled = false,
      _isRewardsEnabled = false,
      _showMiningListTile = false,
      _showTelegramListTile = false,
      _showMyOrdersListTile = false,
      _showRewardsListTile = false,
      _showCampaignOnLaunch = true,
      _sortByCreationDate = true;

  String customError;
  String customErrorAR;
  String amount;
  String iosAppVersion;
  String androidAppVersion;
  String iOSAppId;
  String _telegramPublicLink;
  String _telegramIDBotLink;
  String versionNumber;
  String buildNumber;
  String version;
  String _campaignName;
  String _campaignContents;
  String _campaignContentsAR;
  String _miningCampaignName;
  String _rewardCampaignName;
  String _miningCampaignContents;
  String _miningCampaignContentsAR;
  String _rewardCampaignContents;
  String _rewardCampaignContentsAR;
  int amountWithFee;
  int amountWithoutFee;
  int _driverCashIn;
  int _driverUsdtIn;
  int _driverUsdtOut;
  int _driverCashOut;
  int _usdtSent;
  int _usdtIn;
  int _cashIn;
  int _cashOut;
  int _usdtOut;
  String smallAmountsGoogleSheetURL;
  String largeAmountsGoogleSheetURL;

  String smallAmountsSpreadSheetID;
  String largeAmountsSpreadSheetID;
  String worksheetTitle;

  List<dynamic> cities;
  List<dynamic> _bansList;
  List<dynamic> _driversDrawerList;
  List<dynamic> _feedbackReceiversList;
  List<dynamic> _allowedPeopleToAddOrRemoveMiningItems;
  List<dynamic> _allowedPeopleToAddOrRemoveRewardItems;
  List<Driver> _driversList = [];
  String _cryptoCurrencies = "";

  int get cashOut => _cashOut;
  set cashOut(value) {
    _cashOut = value;
  }

  int get usdtOut => _usdtOut;
  set usdtOut(value) {
    _usdtOut = value;
  }

  int get usdtIn => _usdtIn;
  set usdtIn(value) {
    _usdtIn = value;
  }

  int get cashIn => _cashIn;
  set cashIn(value) {
    _cashIn = value;
  }

  int get usdtSent => _usdtSent;
  set usdtSent(value) {
    _usdtSent = value;
  }

  int get driverCashIn => _driverCashIn;
  set driverCashIn(value) {
    _driverCashIn = value;
  }

  int get driverUsdtOut => _driverUsdtOut;
  set driverUsdtOut(value) {
    _driverUsdtOut = value;
  }

  int get driverUsdtIn => _driverUsdtIn;
  set driverUsdtIn(value) {
    _driverUsdtIn = value;
  }

  int get driverCashOut => _driverCashOut;
  set driverCashOut(value) {
    _driverCashOut = value;
  }

  String get loggedInUserPhoneNumber => _firebaseAuth?.currentUser?.phoneNumber;

  bool get isSundayOff => _isSundayOff;
  set isSundayOff(value) {
    _isSundayOff = value;
  }

  bool get checkForOpeningHours => _checkForOpeningHours;
  set checkForOpeningHours(value) {
    _checkForOpeningHours = value;
  }

  bool get checkForMinimumOrder => _checkForMinimumOrder;
  set checkForMinimumOrder(value) {
    _checkForMinimumOrder = value;
  }

  bool get checkForRoot => _checkForRoot;
  set checkForRoot(value) {
    _checkForRoot = value;
  }

  bool get showSellRate => _showSellRate;
  set showSellRate(value) {
    _showSellRate = value;
  }

  bool get openMiningItemDetailsScreen => _openMiningItemDetailsScreen;
  set openMiningItemDetailsScreen(value) {
    _openMiningItemDetailsScreen = value;
  }

  bool get isHoliday => _isHoliday;
  set isHoliday(value) {
    _isHoliday = value;
  }

  bool get showCoachMark => _showCoachMark;
  set showCoachMark(value) {
    _showCoachMark = value;
  }

  String get coachMarkText => _coachMarkText;
  set coachMarkText(value) {
    _coachMarkText = value;
  }

  String get lastResetDate => _lastResetDate;
  set lastResetDate(value) {
    _lastResetDate = value;
  }

  String get coachMarkTextAR => _coachMarkTextAR;
  set coachMarkTextAR(value) {
    _coachMarkTextAR = value;
  }

  String get telegramPublicLink => _telegramPublicLink;
  set telegramPublicLink(value) {
    _telegramPublicLink = value;
  }

  String get telegramIDBotLink => _telegramIDBotLink;
  set telegramIDBotLink(value) {
    _telegramIDBotLink = value;
  }

  String get coachMarkCampaign => _coachMarkCampaign;
  set coachMarkCampaign(value) {
    _coachMarkCampaign = value;
  }

  bool get forceUpdate => _forceUpdate;

  set forceUpdate(value) {
    _forceUpdate = value;
  }

  String get weekdayOpeningHours => _weekdayOpeningHours;

  set weekdayOpeningHours(value) {
    _weekdayOpeningHours = value;
  }

  String get campaignName => _campaignName;
  set campaignName(value) {
    _campaignName = value;
  }

  String get feedbackSuccessMessage => _feedbackSuccessMessage;
  set feedbackSuccessMessage(value) {
    _feedbackSuccessMessage = value;
  }

  String get feedbackSuccessMessageAR => _feedbackSuccessMessageAR;
  set feedbackSuccessMessageAR(value) {
    _feedbackSuccessMessageAR = value;
  }

  String get campaignContents => _campaignContents;
  set campaignContents(value) {
    _campaignContents = value;
  }

  String get campaignContentsAR => _campaignContentsAR;
  set campaignContentsAR(value) {
    _campaignContentsAR = value;
  }

  String get miningCampaignName => _miningCampaignName;
  set miningCampaignName(value) {
    _miningCampaignName = value;
  }

  String get rewardCampaignName => _rewardCampaignName;
  set rewardCampaignName(value) {
    _rewardCampaignName = value;
  }

  String get miningCampaignContents => _miningCampaignContents;
  set miningCampaignContents(value) {
    _miningCampaignContents = value;
  }

  String get miningCampaignContentsAR => _miningCampaignContentsAR;
  set miningCampaignContentsAR(value) {
    _miningCampaignContentsAR = value;
  }

  String get rewardCampaignContents => _rewardCampaignContents;
  set rewardCampaignContents(value) {
    _rewardCampaignContents = value;
  }

  String get rewardCampaignContentsAR => _rewardCampaignContentsAR;
  set rewardCampaignContentsAR(value) {
    _rewardCampaignContentsAR = value;
  }

  String get minableItemSearchBarHintText => _minableItemSearchBarHintText;
  set minableItemSearchBarHintText(value) {
    _minableItemSearchBarHintText = value;
  }

  String get minableItemSearchBarHintTextAR => _minableItemSearchBarHintTextAR;
  set minableItemSearchBarHintTextAR(value) {
    _minableItemSearchBarHintTextAR = value;
  }

  String get weekdayClosingHours => _weekdayClosingHours;
  set weekdayClosingHours(value) {
    _weekdayClosingHours = value;
  }

  String get detailsAboutYourLocationHint => _detailsAboutYourLocationHint;
  set detailsAboutYourLocationHint(value) {
    _detailsAboutYourLocationHint = value;
  }

  String get signalsGroupWalletAddress => _signalsGroupWalletAddress;
  set signalsGroupWalletAddress(value) {
    _signalsGroupWalletAddress = value;
  }

  String get miningDisabledMessage => _miningDisabledMessage;
  set miningDisabledMessage(value) {
    _miningDisabledMessage = value;
  }

  String get miningDisabledMessageAR => _miningDisabledMessageAR;
  set miningDisabledMessageAR(value) {
    _miningDisabledMessageAR = value;
  }

  String get rewardsDisabledMessage => _rewardsDisabledMessage;
  set rewardsDisabledMessage(value) {
    _rewardsDisabledMessage = value;
  }

  String get rewardsDisabledMessageAR => _rewardsDisabledMessageAR;
  set rewardsDisabledMessageAR(value) {
    _rewardsDisabledMessageAR = value;
  }

  String get contactUsNumber => _contactUsNumber;
  set contactUsNumber(value) {
    _contactUsNumber = value;
  }

  String get mainCurrency => _mainCurrency;
  set mainCurrency(value) {
    _mainCurrency = value;
  }

  String get weekendOpeningHours => _weekendOpeningHours;
  set weekendOpeningHours(value) {
    _weekendOpeningHours = value;
  }

  String get salesNumber => _salesNumber;
  set salesNumber(value) {
    _salesNumber = value;
  }

  String get profitabilityHintText => _profitabilityHintText;
  set profitabilityHintText(value) {
    _profitabilityHintText = value;
  }

  String get miningInformationDialogText => _miningInformationDialogText;
  set miningInformationDialogText(value) {
    _miningInformationDialogText = value;
  }

  String get miningInformationDialogTextAR => _miningInformationDialogTextAR;
  set miningInformationDialogTextAR(value) {
    _miningInformationDialogTextAR = value;
  }

  String get rewardInformationDialogText => _rewardInformationDialogText;
  set rewardInformationDialogText(value) {
    _rewardInformationDialogText = value;
  }

  String get rewardInformationDialogTextAR => _rewardInformationDialogTextAR;
  set rewardInformationDialogTextAR(value) {
    _rewardInformationDialogTextAR = value;
  }

  String get minableCoinsHintText => _minableCoinsHintText;
  set minableCoinsHintText(value) {
    _minableCoinsHintText = value;
  }

  String get priceHintText => _priceHintText;
  set priceHintText(value) {
    _priceHintText = value;
  }

  String get powerConsumptionHintText => _powerConsumptionHintText;
  set powerConsumptionHintText(value) {
    _powerConsumptionHintText = value;
  }

  String get signalsSupportNumber => _signalsSupportNumber;
  set signalsSupportNumber(value) {
    _signalsSupportNumber = value;
  }

  String get salesEmail => _salesEmail;
  set salesEmail(value) {
    _salesEmail = value;
  }

  String get supportEmail => _supportEmail;
  set supportEmail(value) {
    _supportEmail = value;
  }

  String get supportNumber => _supportNumber;
  set supportNumber(value) {
    _supportNumber = value;
  }

  String get website => _website;
  set website(value) {
    _website = value;
  }

  String get github => _github;

  set github(value) {
    _github = value;
  }

  String get linkedIn => _linkedIn;

  set linkedIn(value) {
    _linkedIn = value;
  }

  String get twitter => _twitter;

  set twitter(value) {
    _twitter = value;
  }

  String get instagram => _instagram;

  set instagram(value) {
    _instagram = value;
  }

  String get telegram => _telegram;

  set telegram(value) {
    _telegram = value;
  }

  String get facebook => _facebook;

  set facebook(value) {
    _facebook = value;
  }

  String get tiktok => _tiktok;

  set tiktok(value) {
    _tiktok = value;
  }

  String get weekendClosingHours => _weekendClosingHours;

  set weekendClosingHours(value) {
    _weekendClosingHours = value;
  }

  num get fiftyToHundred => _fiftyToHundred;
  set fiftyToHundred(value) {
    _fiftyToHundred = value;
  }

  num get newsUpdateDuration => _newsUpdateDuration;
  set newsUpdateDuration(value) {
    _newsUpdateDuration = value;
  }

  num get loadUpdateDuration => _loadUpdateDuration;
  set loadUpdateDuration(value) {
    _loadUpdateDuration = value;
  }

  num get myProfitFromSignals => _myProfitFromSignals;
  set myProfitFromSignals(value) {
    _myProfitFromSignals = value;
  }

  num get addToAhmadSalary => _addToAhmadSalary;
  set addToAhmadSalary(value) {
    _addToAhmadSalary = value;
  }

  num get totalProfitFromSignals => _totalProfitFromSignals;
  set totalProfitFromSignals(value) {
    _totalProfitFromSignals = value;
  }

  num get totalProfit => _totalProfit;
  set totalProfit(value) {
    _totalProfit = value;
  }

  num get myPercentageFromSignals => _myPercentageFromSignals;
  set myPercentageFromSignals(value) {
    _myPercentageFromSignals = value;
  }

  num get coinsToJoinTelegram => _coinsToJoinTelegram;
  set coinsToJoinTelegram(value) {
    _coinsToJoinTelegram = value;
  }

  num get hundredToThousand => _hundredToThousand;

  set hundredToThousand(value) {
    _hundredToThousand = value;
  }

  num get thousandToThreeThousand => _thousandToThreeThousand;

  set thousandToThreeThousand(value) {
    _thousandToThreeThousand = value;
  }

  num get threeThousandToFiveThousand => _threeThousandToFiveThousand;

  set threeThousandToFiveThousand(value) {
    _threeThousandToFiveThousand = value;
  }

  num get fiveThousandToTenThousand => _fiveThousandToTenThousand;

  set fiveThousandToTenThousand(value) {
    _fiveThousandToTenThousand = value;
  }

  num get smallAmountsLimit => _smallAmountsLimit;

  set smallAmountsLimit(value) {
    _smallAmountsLimit = value;
  }

  num get sellFiftyToHundred => _sellFiftyToHundred;

  set sellFiftyToHundred(value) {
    _sellFiftyToHundred = value;
  }

  num get sellHundredToThousand => _sellHundredToThousand;

  set sellHundredToThousand(value) {
    _sellHundredToThousand = value;
  }

  num get sellThousandToThreeThousand => _sellThousandToThreeThousand;

  set sellThousandToThreeThousand(value) {
    _sellThousandToThreeThousand = value;
  }

  num get sellThreeThousandToFiveThousand => _sellThreeThousandToFiveThousand;

  set sellThreeThousandToFiveThousand(value) {
    _sellThreeThousandToFiveThousand = value;
  }

  num get sellFiveThousandToTenThousand => _sellFiveThousandToTenThousand;

  set sellFiveThousandToTenThousand(value) {
    _sellFiveThousandToTenThousand = value;
  }

  num get signalsSubscriptionPrice => _signalsSubscriptionPrice;

  set signalsSubscriptionPrice(value) {
    _signalsSubscriptionPrice = value;
  }

  bool get isAdmin => _isAdmin;
  set isAdmin(value) {
    _isAdmin = value;
  }

  bool get feedbackReceiver => _feedbackReceiver;
  set feedbackReceiver(value) {
    _feedbackReceiver = value;
  }

  bool get scrollToEndInTelegramScreen => _scrollToEndInTelegramScreen;
  set scrollToEndInTelegramScreen(value) {
    _scrollToEndInTelegramScreen = value;
  }

  bool get showLargeOrders => _showLargeOrders;
  set showLargeOrders(value) {
    _showLargeOrders = value;
  }

  bool get showMisc => _showMisc;
  set showMisc(value) {
    _showMisc = value;
  }

  bool get showAddToAhmadSalary => _showAddToAhmadSalary;
  set showAddToAhmadSalary(value) {
    _showAddToAhmadSalary = value;
  }

  bool get showCryptoCurrencyNews => _showCryptoCurrencyNews;
  set showCryptoCurrencyNews(value) {
    _showCryptoCurrencyNews = value;
  }

  bool get shouldLoadAgainAfterTimer => _shouldLoadAgainAfterTimer;
  set shouldLoadAgainAfterTimer(value) {
    _shouldLoadAgainAfterTimer = value;
  }

  bool get showSendUsYourFeedbacks => _showSendUsYourFeedbacks;
  set showSendUsYourFeedbacks(value) {
    _showSendUsYourFeedbacks = value;
  }

  bool get showChangeLanguage => _showChangeLanguage;
  set showChangeLanguage(value) {
    _showChangeLanguage = value;
  }

  bool get showTelegramDialog => _showTelegramDialog;
  set showTelegramDialog(value) {
    _showTelegramDialog = value;
  }

  bool get allowedToCheckCustomersBalance => _allowedToCheckCustomersBalance;
  set allowedToCheckCustomersBalance(value) {
    _allowedToCheckCustomersBalance = value;
  }

  bool get showSortingButton => _showSortingButton;
  set showSortingButton(value) {
    _showSortingButton = value;
  }

  bool get showMinableItemSearchBar => _showMinableItemSearchBar;
  set showMinableItemSearchBar(value) {
    _showMinableItemSearchBar = value;
  }

  bool get isBanned => _isBanned;
  set isBanned(value) {
    _isBanned = value;
  }

  bool get isMiningEnabled => _isMiningEnabled;
  set isMiningEnabled(value) {
    _isMiningEnabled = value;
  }

  bool get isRewardsEnabled => _isRewardsEnabled;
  set isRewardsEnabled(value) {
    _isRewardsEnabled = value;
  }

  bool get showMiningListTile => _showMiningListTile;
  set showMiningListTile(value) {
    _showMiningListTile = value;
  }

  bool get showTelegramListTile => _showTelegramListTile;
  set showTelegramListTile(value) {
    _showTelegramListTile = value;
  }

  bool get showMyOrdersListTile => _showMyOrdersListTile;
  set showMyOrdersListTile(value) {
    _showMyOrdersListTile = value;
  }

  bool get showRewardsListTile => _showRewardsListTile;
  set showRewardsListTile(value) {
    _showRewardsListTile = value;
  }

  bool get showCampaignOnLaunch => _showCampaignOnLaunch;
  set showCampaignOnLaunch(value) {
    _showCampaignOnLaunch = value;
  }

  bool get sortByCreationDate => _sortByCreationDate;
  set sortByCreationDate(value) {
    _sortByCreationDate = value;
  }

  List<dynamic> get bansList => _bansList;
  set bansList(value) {
    _bansList = value;
  }

  List<dynamic> get driversDrawerList => _driversDrawerList;
  set driversDrawerList(value) {
    _driversDrawerList = value;
  }

  List<dynamic> get feedbackReceiversList => _feedbackReceiversList;
  set feedbackReceiversList(value) {
    _feedbackReceiversList = value;
  }

  List<Driver> get driversList => _driversList;
  set driversList(value) {
    _driversList = value;
  }

  String get cryptoCurrencies => _cryptoCurrencies;
  set cryptoCurrencies(value) {
    _cryptoCurrencies = value;
  }

  List<dynamic> get allowedPeopleToAddOrRemoveMiningItems =>
      _allowedPeopleToAddOrRemoveMiningItems;
  set allowedPeopleToAddOrRemoveMiningItems(value) {
    _allowedPeopleToAddOrRemoveMiningItems = value;
  }

  List<dynamic> get allowedPeopleToAddOrRemoveRewardItems =>
      _allowedPeopleToAddOrRemoveRewardItems;
  set allowedPeopleToAddOrRemoveRewardItems(value) {
    _allowedPeopleToAddOrRemoveRewardItems = value;
  }

  void fillFieldsFromData() {
    _signalsSubscriptionPrice =
        appInfoSnapshot['signalsSubscriptionPrice'] ?? 30;
    _newsUpdateDuration = appInfoSnapshot['newsUpdateDuration'] ?? 5;
    _loadUpdateDuration = appInfoSnapshot['loadUpdateDuration'] ?? 5;
    _myPercentageFromSignals = appInfoSnapshot['myPercentageFromSignals'] ?? 2;
    _coinsToJoinTelegram = appInfoSnapshot['coinsToJoinTelegram'] ?? 61;
    _myProfitFromSignals = appInfoSnapshot['myProfitFromSignals'] ?? 0;
    _addToAhmadSalary = appInfoSnapshot['addToAhmadSalary'] ?? 0;
    _totalProfit = appInfoSnapshot['totalProfit'] ?? 0;
    _totalProfitFromSignals = appInfoSnapshot['totalProfitFromSignals'] ?? 0;

    fiftyToHundred = ratesAppInfoSnapshot['50to100'] ?? 7;
    hundredToThousand = ratesAppInfoSnapshot['100to1000'] ?? 5;
    thousandToThreeThousand = ratesAppInfoSnapshot['1000to3000'] ?? 4.5;
    threeThousandToFiveThousand = ratesAppInfoSnapshot['3000to5000'] ?? 4;
    fiveThousandToTenThousand = ratesAppInfoSnapshot['5000to10000'] ?? 4;
    sellFiftyToHundred = sellRatesAppInfoSnapshot['50to100'] ?? 7;
    sellHundredToThousand = sellRatesAppInfoSnapshot['100to1000'] ?? 5;
    sellThousandToThreeThousand = sellRatesAppInfoSnapshot['1000to3000'] ?? 4.5;
    sellThreeThousandToFiveThousand =
        sellRatesAppInfoSnapshot['3000to5000'] ?? 4;
    sellFiveThousandToTenThousand =
        sellRatesAppInfoSnapshot['5000to10000'] ?? 4;

    isAdmin = appInfoSnapshot['admins']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _feedbackReceiver = appInfoSnapshot['feedbackReceivers']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _feedbackReceiversList = appInfoSnapshot['feedbackReceivers'];

    _scrollToEndInTelegramScreen =
        appInfoSnapshot['scrollToEndInTelegramScreen'] ?? false;

    _showLargeOrders = appInfoSnapshot['largeOrderAccess']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _showMisc = appInfoSnapshot['showMisc']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _showAddToAhmadSalary = appInfoSnapshot['showAddToAhmadSalary']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _allowedToCheckCustomersBalance =
        appInfoSnapshot['allowedToCheckCustomersBalance']
            .contains(_firebaseAuth?.currentUser?.phoneNumber);

    isBanned = appInfoSnapshot['banned']
        .contains(_firebaseAuth?.currentUser?.phoneNumber);

    _cryptoCurrencies = appInfoSnapshot['cryptoCurrencies'] ?? "";

    _showSendUsYourFeedbacks =
        appInfoSnapshot['showSendUsYourFeedbacks'] ?? false;
    _showChangeLanguage = appInfoSnapshot['showChangeLanguage'] ?? false;
    _showTelegramDialog = appInfoSnapshot['showTelegramDialog'] ?? false;
    _showCryptoCurrencyNews = appInfoSnapshot['showCryptoCurrencyNews'] ?? true;
    _shouldLoadAgainAfterTimer =
        appInfoSnapshot['shouldLoadAgainAfterTimer'] ?? true;
    sortByCreationDate = appInfoSnapshot['sortByCreationDate'] ?? true;
    _checkForMinimumOrder = appInfoSnapshot['checkForMinimumOrder'] ?? true;
    _isMiningEnabled = appInfoSnapshot['isMiningEnabled'] ?? true;
    _isRewardsEnabled = appInfoSnapshot['isRewardsEnabled'] ?? true;
    _showMiningListTile = appInfoSnapshot['showMiningListTile'] ?? true;
    _showTelegramListTile = appInfoSnapshot['showTelegramListTile'] ?? true;
    _showMyOrdersListTile = appInfoSnapshot['showMyOrdersListTile'] ?? true;
    _showRewardsListTile = appInfoSnapshot['showRewardsListTile'] ?? true;
    _showCampaignOnLaunch = appInfoSnapshot['showCampaignOnLaunch'] ?? true;
    _showSortingButton = appInfoSnapshot['showSortingButton'] ?? true;
    _showCoachMark = appInfoSnapshot['showCoachMark'] ?? true;
    _showMinableItemSearchBar =
        appInfoSnapshot['showMinableItemSearchBar'] ?? true;

    _miningInformationDialogText =
        appInfoSnapshot['miningInformationDialogText'] ?? "";
    _miningInformationDialogTextAR =
        appInfoSnapshot['miningInformationDialogTextAR'] ?? "";
    _rewardInformationDialogText =
        appInfoSnapshot['rewardInformationDialogText'] ?? "";
    _rewardInformationDialogTextAR =
        appInfoSnapshot['rewardInformationDialogTextAR'] ?? "";
    _profitabilityHintText = appInfoSnapshot['profitabilityHintText'] ?? "";
    _lastResetDate = appInfoSnapshot['lastResetDate'] ?? "";
    _coachMarkText = appInfoSnapshot['coachMarkText'] ?? "";
    _coachMarkTextAR = appInfoSnapshot['coachMarkTextAR'] ?? "";
    _coachMarkCampaign = appInfoSnapshot['coachMarkCampaign'] ?? "";
    _minableCoinsHintText = appInfoSnapshot['minableCoinsHintText'] ?? "";
    _priceHintText = appInfoSnapshot['priceHintText'] ?? "";
    _campaignName = appInfoSnapshot['campaignName'] ?? "";
    _feedbackSuccessMessage = appInfoSnapshot['feedbacksuccessmessage'] ?? "";
    _feedbackSuccessMessageAR =
        appInfoSnapshot['feedbackSuccessMessageAR'] ?? "";
    _campaignContents = appInfoSnapshot['campaignContents'] ?? "";
    _campaignContentsAR = appInfoSnapshot['campaignContentsAR'] ?? "";
    _miningCampaignName = appInfoSnapshot['miningCampaignName'] ?? "";
    _rewardCampaignName = appInfoSnapshot['rewardCampaignName'] ?? "";
    _miningCampaignContents = appInfoSnapshot['miningCampaignContents'] ?? "";
    _miningCampaignContentsAR =
        appInfoSnapshot['miningCampaignContentsAR'] ?? "";
    _rewardCampaignContents = appInfoSnapshot['rewardCampaignContents'] ?? "";
    _rewardCampaignContentsAR =
        appInfoSnapshot['rewardCampaignContentsAR'] ?? "";
    _powerConsumptionHintText =
        appInfoSnapshot['powerConsumptionHintText'] ?? "";

    bansList = appInfoSnapshot['banned'];
    _detailsAboutYourLocationHint =
        appInfoSnapshot['detailsAboutYourLocationHint'] ?? "";

    _signalsGroupWalletAddress =
        appInfoSnapshot['signalsGroupWalletAddress'] ?? "";

    driversDrawerList = appInfoSnapshot['drivers'];

    salesEmail = appInfoSnapshot['salesEmail'];
    supportEmail = appInfoSnapshot['supportEmail'];
    supportNumber = appInfoSnapshot['supportNumber'];
    website = appInfoSnapshot['website'];
    tiktok = appInfoSnapshot['tiktok'];
    github = appInfoSnapshot['github'];
    linkedIn = appInfoSnapshot['linkedIn'];
    twitter = appInfoSnapshot['twitter'];
    instagram = appInfoSnapshot['instagram'];
    telegram = appInfoSnapshot['telegram'];
    facebook = appInfoSnapshot['facebook'];
    _signalsSupportNumber = appInfoSnapshot['signalsSupportNumber'];

    _allowedPeopleToAddOrRemoveMiningItems =
        appInfoSnapshot['allowedPeopleToAddOrRemoveMiningItems'];

    _allowedPeopleToAddOrRemoveRewardItems =
        appInfoSnapshot['allowedPeopleToAddOrRemoveRewardItems'];

    salesNumber = appInfoSnapshot['salesNumber'];
    _miningDisabledMessage =
        appInfoSnapshot['miningDisabledMessage'] ?? "Coming Soon!";
    _miningDisabledMessageAR =
        appInfoSnapshot['miningDisabledMessageAR'] ?? "Coming Soon!";
    _rewardsDisabledMessage =
        appInfoSnapshot['rewardsDisabledMessage'] ?? "Coming Soon!";
    _rewardsDisabledMessageAR =
        appInfoSnapshot['rewardsDisabledMessageAR'] ?? "Coming Soon!";

    largeAmountsGoogleSheetURL = appInfoSnapshot['largeAmountsScriptURL'] ??
        'https://script.google.com/macros/s/AKfycbzWblzX2gCXcg0q1m5roVl8B8j-Oh5f3vkZHIN6d6scUVgRvTUXlytRy5s7UIvpdGMm/exec';

    smallAmountsSpreadSheetID = appInfoSnapshot['smallAmountsSpreadSheetID'] ??
        '1vKJVTEdLZqRgiWfzdv2KekF76yAGkBeyHuZiMyw6IYY';

    largeAmountsSpreadSheetID = appInfoSnapshot['largeAmountsSpreadSheetID'] ??
        '1vKJVTEdLZqRgiWfzdv2KekF76yAGkBeyHuZiMyw6IYY';

    forceUpdate = appInfoSnapshot['forceUpdate'] ?? false;
    worksheetTitle = appInfoSnapshot['worksheetTitle'] ?? 'Sheet1';

    _minableItemSearchBarHintText =
        appInfoSnapshot['minableItemSearchBarHintText'] ?? '';
    _minableItemSearchBarHintTextAR =
        appInfoSnapshot['minableItemSearchBarHintTextAR'] ?? '';

    _telegramPublicLink = appInfoSnapshot['telegramPublicLink'] ?? '';
    _telegramIDBotLink = appInfoSnapshot['telegramIDBotLink'] ?? '';
    iOSAppId = appInfoSnapshot['iosAppID'] ?? '';
    customError = appInfoSnapshot['customError'] ?? '';
    customErrorAR = appInfoSnapshot['customErrorAR'] ?? '';
    submissionTextAR = appInfoSnapshot['submissionTextAR'] ?? '';
    submissionText = appInfoSnapshot['submissionText'] ?? '';
    iosAppVersion = appInfoSnapshot['iosVersion'] ?? '';
    androidAppVersion = appInfoSnapshot['androidVersion'] ?? '';
    smallAmountsLimit = num.tryParse(appInfoSnapshot['smallAmountsLimit']) ?? 0;
    isSundayOff = appInfoSnapshot['isSundayOff'] ?? false;
    checkForOpeningHours = appInfoSnapshot['checkForOpeningHours'];
    _checkForRoot = appInfoSnapshot['checkForRoot'] ?? false;
    _showSellRate = appInfoSnapshot['showSellRate'] ?? false;
    openMiningItemDetailsScreen =
        appInfoSnapshot['openMiningItemDetailsScreen'] ?? false;

    isHoliday = appInfoSnapshot['isHoliday'] ?? false;
    showCustomError = appInfoSnapshot['showCustomError'] ?? false;
    contactUsNumber = appInfoSnapshot['contactUsNumber'] ?? '+96171215047';
    _mainCurrency = appInfoSnapshot['mainCurrency'] ?? 'USDT';
    weekdayOpeningHours =
        appInfoSnapshot['weekdayWorkingHours'].toString().split('-')[0] ??
            false;
    weekdayClosingHours =
        appInfoSnapshot['weekdayWorkingHours'].toString().split('-')[1] ??
            false;
    weekendOpeningHours =
        appInfoSnapshot['weekendWorkingHours'].toString().split('-')[0] ??
            false;
    weekendClosingHours =
        appInfoSnapshot['weekendWorkingHours'].toString().split('-')[1] ??
            false;

    minimumOrder = appInfoSnapshot['minimumOrder'] ?? 0;
    cities = appInfoSnapshot['cities'] ?? 0;
  }
}
