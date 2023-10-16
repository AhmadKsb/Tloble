import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/src/models/customer.dart';
import 'package:flutter_ecommerce_app/src/models/employee.dart';

class HomeScreenController {
  final Map<String, dynamic>? ratesAppInfoSnapshot;
  Map<String, dynamic>? appInfoSnapshot;
  final Map<String, dynamic>? sellRatesAppInfoSnapshot;

  HomeScreenController(
    this.ratesAppInfoSnapshot,
    this.appInfoSnapshot,
    this.sellRatesAppInfoSnapshot,
  ) {
    if (appInfoSnapshot != null)
      fillFieldsFromData(appInfoSnapshott: appInfoSnapshot);
  }

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  num? _newsUpdateDuration,
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

  String? _weekdayOpeningHours,
      _lastResetDate,
      _orderSummaryDisclaimer,
      _orderSummaryDisclaimerAR,
      _feedbackSuccessMessage,
      _feedbackSuccessMessageAR,
      _signalsGroupWalletAddress,
      _contactUsNumber,
      _mainCurrency,
      nextText,
      nextTextSize,
      nextTextColor,
      nextTextSizeAR,
      nextTextColorAR,
      nextTextAR,
      submissionText,
      submissionTextAR,
      _detailsAboutYourLocationHint,
      _weekdayClosingHours,
      _weekendOpeningHours,
      _weekendClosingHours,
      _coachMarkText,
      _coachMarkTextAR,
      _coachMarkCampaign,
      _aedConversion,
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

  bool? _isSundayOff,
      _hideImage,
      _showSendUsYourFeedbacks,
      _showChangeLanguage,
      _showTelegramDialog,
      _showCryptoCurrencyNews,
      _shouldLoadAgainAfterTimer,
      _checkForOpeningHours,
      _showSellRate,
      _hideContents,
      _showDeactivateAccount,
      _hideDisclaimer,
      _checkForRoot,
      _checkForMinimumOrder,
      _openMiningItemDetailsScreen,
      _isHoliday,
      _showCoachMark,
      _showProductPrice,
      _showProductsSubtotal,
      showCustomError,
      _forceUpdate,
      _showMinableItemSearchBar,
      _feedbackReceiver = false,
      _scrollToEndInTelegramScreen = false,
      _showLargeOrders = false,
      _showMisc = false,
      _showAddToAhmadSalary = false,
      _forceShowCoachmark = false,
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

  String? customError;
  String? customErrorAR;
  String? amount;
  String? iosAppVersion;
  String? SearchInOrdersCollectionName;
  String? androidAppVersion;
  String? iOSAppId;
  String? androidAppId;
  String? _telegramPublicLink;
  String? _telegramIDBotLink;
  String? versionNumber;
  String? buildNumber;
  String? version;
  String? _campaignName;
  String? _campaignContents;
  String? _campaignContentsAR;
  String? _miningCampaignName;
  String? _rewardCampaignName;
  String? _miningCampaignContents;
  String? _miningCampaignContentsAR;
  String? _rewardCampaignContents;
  String? _rewardCampaignContentsAR;
  int? amountWithFee;
  int? amountWithoutFee;
  int? _driverCashIn;
  int? _driverUsdtIn;
  int? _driverUsdtOut;
  int? _driverCashOut;
  int? _usdtSent;
  int? _usdtIn;
  int? _cashIn;
  int? _cashOut;
  int? _usdtOut;
  String? smallAmountsGoogleSheetURL;
  String? spreadSheetScriptURL;
  HomeScreenControllerView? homeScreenControllerView;

  String? spreadSheetID;
  String? largeAmountsSpreadSheetID;
  String? worksheetTitle;

  Customer? _customer;

  List<dynamic>? admins;
  List<dynamic>? canCheckOtherCustomersOrders;
  List<dynamic>? cities;
  List<dynamic>? _bansList;
  List<dynamic>? _employeesList;
  List<dynamic>? _feedbackReceiversList;
  List<dynamic>? _allowedPeopleToAddOrRemoveMiningItems;
  List<dynamic>? _allowedPeopleToAddOrRemoveRewardItems;
  List<dynamic> productsTitles = [];
  List<dynamic> productsQuantities = [];
  List<dynamic> productsLinks = [];
  List<dynamic> productsColors = [];
  List<dynamic> productsSizes = [];
  List<dynamic> productsPrices = [];
  List<dynamic> productsImages = [];
  List<Employee> _employees = [];
  String _cryptoCurrencies = "";

  int? get cashOut => _cashOut;
  set cashOut(value) {
    _cashOut = value;
  }

  void setView(HomeScreenControllerView view) {
    this.homeScreenControllerView = view;
  }

  void refreshView() {
    this.homeScreenControllerView?.refreshState();
  }

  void jumpToCartScreen() {
    this.homeScreenControllerView?.jumpToCartScreen();
  }

  int? get usdtOut => _usdtOut;
  set usdtOut(value) {
    _usdtOut = value;
  }

  int? get usdtIn => _usdtIn;
  set usdtIn(value) {
    _usdtIn = value;
  }

  int? get cashIn => _cashIn;
  set cashIn(value) {
    _cashIn = value;
  }

  int? get usdtSent => _usdtSent;
  set usdtSent(value) {
    _usdtSent = value;
  }

  int? get driverCashIn => _driverCashIn;
  set driverCashIn(value) {
    _driverCashIn = value;
  }

  int? get driverUsdtOut => _driverUsdtOut;
  set driverUsdtOut(value) {
    _driverUsdtOut = value;
  }

  int? get driverUsdtIn => _driverUsdtIn;
  set driverUsdtIn(value) {
    _driverUsdtIn = value;
  }

  int? get driverCashOut => _driverCashOut;
  set driverCashOut(value) {
    _driverCashOut = value;
  }

  String? get loggedInUserPhoneNumber => _firebaseAuth.currentUser?.phoneNumber;

  bool? get isSundayOff => _isSundayOff;
  set isSundayOff(value) {
    _isSundayOff = value;
  }

  bool? get hideImage => _hideImage;
  set hideImage(value) {
    _hideImage = value;
  }

  bool? get checkForOpeningHours => _checkForOpeningHours;
  set checkForOpeningHours(value) {
    _checkForOpeningHours = value;
  }

  bool? get checkForMinimumOrder => _checkForMinimumOrder;
  set checkForMinimumOrder(value) {
    _checkForMinimumOrder = value;
  }

  Customer? get customer => _customer;
  set customer(value) {
    _customer = value;
  }

  bool? get checkForRoot => _checkForRoot;
  set checkForRoot(value) {
    _checkForRoot = value;
  }

  bool? get showSellRate => _showSellRate;
  set showSellRate(value) {
    _showSellRate = value;
  }

  bool? get hideContents => _hideContents;
  set hideContents(value) {
    _hideContents = value;
  }

  bool? get showDeactivateAccount => _showDeactivateAccount;
  set showDeactivateAccount(value) {
    _showDeactivateAccount = value;
  }

  bool? get hideDisclaimer => _hideDisclaimer;
  set hideDisclaimer(value) {
    _hideDisclaimer = value;
  }

  bool? get openMiningItemDetailsScreen => _openMiningItemDetailsScreen;
  set openMiningItemDetailsScreen(value) {
    _openMiningItemDetailsScreen = value;
  }

  bool? get isHoliday => _isHoliday;
  set isHoliday(value) {
    _isHoliday = value;
  }

  bool? get showCoachMark => _showCoachMark;
  set showCoachMark(value) {
    _showCoachMark = value;
  }

  bool? get showProductPrice => _showProductPrice;
  set showProductPrice(value) {
    _showProductPrice = value;
  }

  bool? get showProductsSubtotal => _showProductsSubtotal;
  set showProductsSubtotal(value) {
    _showProductsSubtotal = value;
  }

  String? get coachMarkText => _coachMarkText;
  set coachMarkText(value) {
    _coachMarkText = value;
  }

  String? get lastResetDate => _lastResetDate;
  set lastResetDate(value) {
    _lastResetDate = value;
  }

  String? get coachMarkTextAR => _coachMarkTextAR;
  set coachMarkTextAR(value) {
    _coachMarkTextAR = value;
  }

  String? get telegramPublicLink => _telegramPublicLink;
  set telegramPublicLink(value) {
    _telegramPublicLink = value;
  }

  String? get telegramIDBotLink => _telegramIDBotLink;
  set telegramIDBotLink(value) {
    _telegramIDBotLink = value;
  }

  String? get coachMarkCampaign => _coachMarkCampaign;
  set coachMarkCampaign(value) {
    _coachMarkCampaign = value;
  }

  bool? get forceShowCoachmark => _forceShowCoachmark;
  set forceShowCoachmark(value) {
    _forceShowCoachmark = value;
  }

  String? get aedConversion => _aedConversion;
  set aedConversion(value) {
    _aedConversion = value;
  }

  bool? get forceUpdate => _forceUpdate;

  set forceUpdate(value) {
    _forceUpdate = value;
  }

  String? get weekdayOpeningHours => _weekdayOpeningHours;

  set weekdayOpeningHours(value) {
    _weekdayOpeningHours = value;
  }

  String? get campaignName => _campaignName;
  set campaignName(value) {
    _campaignName = value;
  }

  String? get orderSummaryDisclaimer => _orderSummaryDisclaimer;
  set orderSummaryDisclaimer(value) {
    _orderSummaryDisclaimer = value;
  }

  String? get orderSummaryDisclaimerAR => _orderSummaryDisclaimerAR;
  set orderSummaryDisclaimerAR(value) {
    _orderSummaryDisclaimerAR = value;
  }

  String? get feedbackSuccessMessage => _feedbackSuccessMessage;
  set feedbackSuccessMessage(value) {
    _feedbackSuccessMessage = value;
  }

  String? get feedbackSuccessMessageAR => _feedbackSuccessMessageAR;
  set feedbackSuccessMessageAR(value) {
    _feedbackSuccessMessageAR = value;
  }

  String? get campaignContents => _campaignContents;
  set campaignContents(value) {
    _campaignContents = value;
  }

  String? get campaignContentsAR => _campaignContentsAR;
  set campaignContentsAR(value) {
    _campaignContentsAR = value;
  }

  String? get miningCampaignName => _miningCampaignName;
  set miningCampaignName(value) {
    _miningCampaignName = value;
  }

  String? get rewardCampaignName => _rewardCampaignName;
  set rewardCampaignName(value) {
    _rewardCampaignName = value;
  }

  String? get miningCampaignContents => _miningCampaignContents;
  set miningCampaignContents(value) {
    _miningCampaignContents = value;
  }

  String? get miningCampaignContentsAR => _miningCampaignContentsAR;
  set miningCampaignContentsAR(value) {
    _miningCampaignContentsAR = value;
  }

  String? get rewardCampaignContents => _rewardCampaignContents;
  set rewardCampaignContents(value) {
    _rewardCampaignContents = value;
  }

  String? get rewardCampaignContentsAR => _rewardCampaignContentsAR;
  set rewardCampaignContentsAR(value) {
    _rewardCampaignContentsAR = value;
  }

  String? get minableItemSearchBarHintText => _minableItemSearchBarHintText;
  set minableItemSearchBarHintText(value) {
    _minableItemSearchBarHintText = value;
  }

  String? get minableItemSearchBarHintTextAR => _minableItemSearchBarHintTextAR;
  set minableItemSearchBarHintTextAR(value) {
    _minableItemSearchBarHintTextAR = value;
  }

  String? get weekdayClosingHours => _weekdayClosingHours;
  set weekdayClosingHours(value) {
    _weekdayClosingHours = value;
  }

  String? get detailsAboutYourLocationHint => _detailsAboutYourLocationHint;
  set detailsAboutYourLocationHint(value) {
    _detailsAboutYourLocationHint = value;
  }

  String? get signalsGroupWalletAddress => _signalsGroupWalletAddress;
  set signalsGroupWalletAddress(value) {
    _signalsGroupWalletAddress = value;
  }

  String? get miningDisabledMessage => _miningDisabledMessage;
  set miningDisabledMessage(value) {
    _miningDisabledMessage = value;
  }

  String? get miningDisabledMessageAR => _miningDisabledMessageAR;
  set miningDisabledMessageAR(value) {
    _miningDisabledMessageAR = value;
  }

  String? get rewardsDisabledMessage => _rewardsDisabledMessage;
  set rewardsDisabledMessage(value) {
    _rewardsDisabledMessage = value;
  }

  String? get rewardsDisabledMessageAR => _rewardsDisabledMessageAR;
  set rewardsDisabledMessageAR(value) {
    _rewardsDisabledMessageAR = value;
  }

  String? get contactUsNumber => _contactUsNumber;
  set contactUsNumber(value) {
    _contactUsNumber = value;
  }

  String? get mainCurrency => _mainCurrency;
  set mainCurrency(value) {
    _mainCurrency = value;
  }

  String? get weekendOpeningHours => _weekendOpeningHours;
  set weekendOpeningHours(value) {
    _weekendOpeningHours = value;
  }

  String? get salesNumber => _salesNumber;
  set salesNumber(value) {
    _salesNumber = value;
  }

  String? get profitabilityHintText => _profitabilityHintText;
  set profitabilityHintText(value) {
    _profitabilityHintText = value;
  }

  String? get miningInformationDialogText => _miningInformationDialogText;
  set miningInformationDialogText(value) {
    _miningInformationDialogText = value;
  }

  String? get miningInformationDialogTextAR => _miningInformationDialogTextAR;
  set miningInformationDialogTextAR(value) {
    _miningInformationDialogTextAR = value;
  }

  String? get rewardInformationDialogText => _rewardInformationDialogText;
  set rewardInformationDialogText(value) {
    _rewardInformationDialogText = value;
  }

  String? get rewardInformationDialogTextAR => _rewardInformationDialogTextAR;
  set rewardInformationDialogTextAR(value) {
    _rewardInformationDialogTextAR = value;
  }

  String? get minableCoinsHintText => _minableCoinsHintText;
  set minableCoinsHintText(value) {
    _minableCoinsHintText = value;
  }

  String? get priceHintText => _priceHintText;
  set priceHintText(value) {
    _priceHintText = value;
  }

  String? get powerConsumptionHintText => _powerConsumptionHintText;
  set powerConsumptionHintText(value) {
    _powerConsumptionHintText = value;
  }

  String? get signalsSupportNumber => _signalsSupportNumber;
  set signalsSupportNumber(value) {
    _signalsSupportNumber = value;
  }

  String? get salesEmail => _salesEmail;
  set salesEmail(value) {
    _salesEmail = value;
  }

  String? get supportEmail => _supportEmail;
  set supportEmail(value) {
    _supportEmail = value;
  }

  String? get supportNumber => _supportNumber;
  set supportNumber(value) {
    _supportNumber = value;
  }

  String? get website => _website;
  set website(value) {
    _website = value;
  }

  String? get github => _github;

  set github(value) {
    _github = value;
  }

  String? get linkedIn => _linkedIn;

  set linkedIn(value) {
    _linkedIn = value;
  }

  String? get twitter => _twitter;

  set twitter(value) {
    _twitter = value;
  }

  String? get instagram => _instagram;

  set instagram(value) {
    _instagram = value;
  }

  String? get telegram => _telegram;

  set telegram(value) {
    _telegram = value;
  }

  String? get facebook => _facebook;

  set facebook(value) {
    _facebook = value;
  }

  String? get tiktok => _tiktok;

  set tiktok(value) {
    _tiktok = value;
  }

  String? get weekendClosingHours => _weekendClosingHours;

  set weekendClosingHours(value) {
    _weekendClosingHours = value;
  }

  num? get fiftyToHundred => _fiftyToHundred;
  set fiftyToHundred(value) {
    _fiftyToHundred = value;
  }

  num? get newsUpdateDuration => _newsUpdateDuration;
  set newsUpdateDuration(value) {
    _newsUpdateDuration = value;
  }

  num? get loadUpdateDuration => _loadUpdateDuration;
  set loadUpdateDuration(value) {
    _loadUpdateDuration = value;
  }

  num? get myProfitFromSignals => _myProfitFromSignals;
  set myProfitFromSignals(value) {
    _myProfitFromSignals = value;
  }

  num? get addToAhmadSalary => _addToAhmadSalary;
  set addToAhmadSalary(value) {
    _addToAhmadSalary = value;
  }

  num? get totalProfitFromSignals => _totalProfitFromSignals;
  set totalProfitFromSignals(value) {
    _totalProfitFromSignals = value;
  }

  num? get totalProfit => _totalProfit;
  set totalProfit(value) {
    _totalProfit = value;
  }

  num? get myPercentageFromSignals => _myPercentageFromSignals;
  set myPercentageFromSignals(value) {
    _myPercentageFromSignals = value;
  }

  num? get coinsToJoinTelegram => _coinsToJoinTelegram;
  set coinsToJoinTelegram(value) {
    _coinsToJoinTelegram = value;
  }

  num? get hundredToThousand => _hundredToThousand;

  set hundredToThousand(value) {
    _hundredToThousand = value;
  }

  num? get thousandToThreeThousand => _thousandToThreeThousand;

  set thousandToThreeThousand(value) {
    _thousandToThreeThousand = value;
  }

  num? get threeThousandToFiveThousand => _threeThousandToFiveThousand;

  set threeThousandToFiveThousand(value) {
    _threeThousandToFiveThousand = value;
  }

  num? get fiveThousandToTenThousand => _fiveThousandToTenThousand;

  set fiveThousandToTenThousand(value) {
    _fiveThousandToTenThousand = value;
  }

  num? get smallAmountsLimit => _smallAmountsLimit;

  set smallAmountsLimit(value) {
    _smallAmountsLimit = value;
  }

  num? get sellFiftyToHundred => _sellFiftyToHundred;

  set sellFiftyToHundred(value) {
    _sellFiftyToHundred = value;
  }

  num? get sellHundredToThousand => _sellHundredToThousand;

  set sellHundredToThousand(value) {
    _sellHundredToThousand = value;
  }

  num? get sellThousandToThreeThousand => _sellThousandToThreeThousand;

  set sellThousandToThreeThousand(value) {
    _sellThousandToThreeThousand = value;
  }

  num? get sellThreeThousandToFiveThousand => _sellThreeThousandToFiveThousand;

  set sellThreeThousandToFiveThousand(value) {
    _sellThreeThousandToFiveThousand = value;
  }

  num? get sellFiveThousandToTenThousand => _sellFiveThousandToTenThousand;

  set sellFiveThousandToTenThousand(value) {
    _sellFiveThousandToTenThousand = value;
  }

  num? get signalsSubscriptionPrice => _signalsSubscriptionPrice;

  set signalsSubscriptionPrice(value) {
    _signalsSubscriptionPrice = value;
  }

  bool? get isAdmin =>
      admins?.contains(_firebaseAuth.currentUser?.phoneNumber) ?? false;

  bool? get canUserCheckOtherCustomersOrders =>
      canCheckOtherCustomersOrders
          ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
      false;

  bool? get feedbackReceiver => _feedbackReceiver;
  set feedbackReceiver(value) {
    _feedbackReceiver = value;
  }

  bool? get scrollToEndInTelegramScreen => _scrollToEndInTelegramScreen;
  set scrollToEndInTelegramScreen(value) {
    _scrollToEndInTelegramScreen = value;
  }

  bool? get showLargeOrders => _showLargeOrders;
  set showLargeOrders(value) {
    _showLargeOrders = value;
  }

  bool? get showMisc => _showMisc;
  set showMisc(value) {
    _showMisc = value;
  }

  bool? get showAddToAhmadSalary => _showAddToAhmadSalary;
  set showAddToAhmadSalary(value) {
    _showAddToAhmadSalary = value;
  }

  bool? get showCryptoCurrencyNews => _showCryptoCurrencyNews;
  set showCryptoCurrencyNews(value) {
    _showCryptoCurrencyNews = value;
  }

  bool? get shouldLoadAgainAfterTimer => _shouldLoadAgainAfterTimer;
  set shouldLoadAgainAfterTimer(value) {
    _shouldLoadAgainAfterTimer = value;
  }

  bool? get showSendUsYourFeedbacks => _showSendUsYourFeedbacks;
  set showSendUsYourFeedbacks(value) {
    _showSendUsYourFeedbacks = value;
  }

  bool? get showChangeLanguage => _showChangeLanguage;
  set showChangeLanguage(value) {
    _showChangeLanguage = value;
  }

  bool? get showTelegramDialog => _showTelegramDialog;
  set showTelegramDialog(value) {
    _showTelegramDialog = value;
  }

  bool? get allowedToCheckCustomersBalance => _allowedToCheckCustomersBalance;
  set allowedToCheckCustomersBalance(value) {
    _allowedToCheckCustomersBalance = value;
  }

  bool? get showSortingButton => _showSortingButton;
  set showSortingButton(value) {
    _showSortingButton = value;
  }

  bool? get showMinableItemSearchBar => _showMinableItemSearchBar;
  set showMinableItemSearchBar(value) {
    _showMinableItemSearchBar = value;
  }

  bool? get isBanned => _isBanned;
  set isBanned(value) {
    _isBanned = value;
  }

  bool? get isMiningEnabled => _isMiningEnabled;
  set isMiningEnabled(value) {
    _isMiningEnabled = value;
  }

  bool? get isRewardsEnabled => _isRewardsEnabled;
  set isRewardsEnabled(value) {
    _isRewardsEnabled = value;
  }

  bool? get showMiningListTile => _showMiningListTile;
  set showMiningListTile(value) {
    _showMiningListTile = value;
  }

  bool? get showTelegramListTile => _showTelegramListTile;
  set showTelegramListTile(value) {
    _showTelegramListTile = value;
  }

  bool? get showMyOrdersListTile => _showMyOrdersListTile;
  set showMyOrdersListTile(value) {
    _showMyOrdersListTile = value;
  }

  bool? get showRewardsListTile => _showRewardsListTile;
  set showRewardsListTile(value) {
    _showRewardsListTile = value;
  }

  bool? get showCampaignOnLaunch => _showCampaignOnLaunch;
  set showCampaignOnLaunch(value) {
    _showCampaignOnLaunch = value;
  }

  bool? get sortByCreationDate => _sortByCreationDate;
  set sortByCreationDate(value) {
    _sortByCreationDate = value;
  }

  List<dynamic>? get bansList => _bansList;
  set bansList(value) {
    _bansList = value;
  }

  List<dynamic>? get employeesList => _employeesList;
  set employeesList(value) {
    _employeesList = value;
  }

  List<dynamic>? get feedbackReceiversList => _feedbackReceiversList;
  set feedbackReceiversList(value) {
    _feedbackReceiversList = value;
  }

  List<Employee> get employees => _employees;
  set employees(value) {
    _employees = value;
  }

  String? get cryptoCurrencies => _cryptoCurrencies;
  set cryptoCurrencies(value) {
    _cryptoCurrencies = value;
  }

  List<dynamic>? get allowedPeopleToAddOrRemoveMiningItems =>
      _allowedPeopleToAddOrRemoveMiningItems;
  set allowedPeopleToAddOrRemoveMiningItems(value) {
    _allowedPeopleToAddOrRemoveMiningItems = value;
  }

  List<dynamic>? get allowedPeopleToAddOrRemoveRewardItems =>
      _allowedPeopleToAddOrRemoveRewardItems;
  set allowedPeopleToAddOrRemoveRewardItems(value) {
    _allowedPeopleToAddOrRemoveRewardItems = value;
  }

  void fillFieldsFromData({var appInfoSnapshott}) {
    if (appInfoSnapshott != null) appInfoSnapshot = appInfoSnapshott;

    _signalsSubscriptionPrice =
        appInfoSnapshot?['signalsSubscriptionPrice'] ?? 30;
    _newsUpdateDuration = appInfoSnapshot?['newsUpdateDuration'] ?? 5;
    _loadUpdateDuration = appInfoSnapshot?['loadUpdateDuration'] ?? 5;
    _myPercentageFromSignals = appInfoSnapshot?['myPercentageFromSignals'] ?? 2;
    _coinsToJoinTelegram = appInfoSnapshot?['coinsToJoinTelegram'] ?? 61;
    _myProfitFromSignals = appInfoSnapshot?['myProfitFromSignals'] ?? 0;
    _addToAhmadSalary = appInfoSnapshot?['addToAhmadSalary'] ?? 0;
    _totalProfit = appInfoSnapshot?['totalProfit'] ?? 0;
    _totalProfitFromSignals = appInfoSnapshot?['totalProfitFromSignals'] ?? 0;

    admins = appInfoSnapshot?['admins'] ?? [];
    canCheckOtherCustomersOrders =
        appInfoSnapshot?['canCheckOtherCustomersOrders'] ?? [];

    _feedbackReceiver = appInfoSnapshot?['FeedbackReceivers']
            ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
        false;

    _feedbackReceiversList = appInfoSnapshot?['FeedbackReceivers'];

    _scrollToEndInTelegramScreen =
        appInfoSnapshot?['scrollToEndInTelegramScreen'] ?? false;

    _showLargeOrders = appInfoSnapshot?['largeOrderAccess']
            ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
        false;

    _showMisc = appInfoSnapshot?['showMisc']
            ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
        false;

    _showAddToAhmadSalary = appInfoSnapshot?['showAddToAhmadSalary']
            ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
        false;

    _allowedToCheckCustomersBalance =
        appInfoSnapshot?['allowedToCheckCustomersBalance']
                ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
            false;

    isBanned = appInfoSnapshot?['banned']
            ?.contains(_firebaseAuth.currentUser?.phoneNumber) ??
        false;

    _cryptoCurrencies = appInfoSnapshot?['cryptoCurrencies'] ?? "";

    _showSendUsYourFeedbacks =
        appInfoSnapshot?['showSendUsYourFeedbacks'] ?? false;
    _showChangeLanguage = appInfoSnapshot?['showChangeLanguage'] ?? false;
    _showTelegramDialog = appInfoSnapshot?['showTelegramDialog'] ?? false;
    _showCryptoCurrencyNews =
        appInfoSnapshot?['showCryptoCurrencyNews'] ?? true;
    _shouldLoadAgainAfterTimer =
        appInfoSnapshot?['shouldLoadAgainAfterTimer'] ?? true;
    sortByCreationDate = appInfoSnapshot?['sortByCreationDate'] ?? true;
    _checkForMinimumOrder = appInfoSnapshot?['checkForMinimumOrder'] ?? true;
    _isMiningEnabled = appInfoSnapshot?['isMiningEnabled'] ?? true;
    _isRewardsEnabled = appInfoSnapshot?['isRewardsEnabled'] ?? true;
    _showMiningListTile = appInfoSnapshot?['showMiningListTile'] ?? true;
    _showTelegramListTile = appInfoSnapshot?['showTelegramListTile'] ?? true;
    _showMyOrdersListTile = appInfoSnapshot?['showMyOrdersListTile'] ?? true;
    _showRewardsListTile = appInfoSnapshot?['showRewardsListTile'] ?? true;
    _showCampaignOnLaunch = appInfoSnapshot?['showCampaignOnLaunch'] ?? true;
    _showSortingButton = appInfoSnapshot?['showSortingButton'] ?? true;
    _showCoachMark = appInfoSnapshot?['showCoachMark'] ?? true;
    _showProductPrice = appInfoSnapshot?['showProductPrice'] ?? true;
    _showProductsSubtotal = appInfoSnapshot?['showProductsSubtotal'] ?? true;
    _forceShowCoachmark = appInfoSnapshot?['forceShowCoachmark'] ?? true;
    _showMinableItemSearchBar =
        appInfoSnapshot?['showMinableItemSearchBar'] ?? true;

    _miningInformationDialogText =
        appInfoSnapshot?['miningInformationDialogText'] ?? "";
    _miningInformationDialogTextAR =
        appInfoSnapshot?['miningInformationDialogTextAR'] ?? "";
    _rewardInformationDialogText =
        appInfoSnapshot?['rewardInformationDialogText'] ?? "";
    _rewardInformationDialogTextAR =
        appInfoSnapshot?['rewardInformationDialogTextAR'] ?? "";
    _profitabilityHintText = appInfoSnapshot?['profitabilityHintText'] ?? "";
    _lastResetDate = appInfoSnapshot?['lastResetDate'] ?? "";
    _coachMarkText = appInfoSnapshot?['coachMarkText'] ?? "";
    _coachMarkTextAR = appInfoSnapshot?['coachMarkTextAR'] ?? "";
    _coachMarkCampaign = appInfoSnapshot?['coachMarkCampaign'] ?? "";
    _aedConversion = appInfoSnapshot?['aedConversion'] ?? "";
    _minableCoinsHintText = appInfoSnapshot?['minableCoinsHintText'] ?? "";
    _priceHintText = appInfoSnapshot?['priceHintText'] ?? "";
    _campaignName = appInfoSnapshot?['campaignName'] ?? "";
    _orderSummaryDisclaimer = appInfoSnapshot?['orderSummaryDisclaimer'] ?? "";
    _orderSummaryDisclaimerAR =
        appInfoSnapshot?['orderSummaryDisclaimerAR'] ?? "";
    _feedbackSuccessMessage = appInfoSnapshot?['feedbacksuccessmessage'] ?? "";
    _feedbackSuccessMessageAR =
        appInfoSnapshot?['feedbackSuccessMessageAR'] ?? "";
    _campaignContents = appInfoSnapshot?['campaignContents'] ?? "";
    _campaignContentsAR = appInfoSnapshot?['campaignContentsAR'] ?? "";
    _miningCampaignName = appInfoSnapshot?['miningCampaignName'] ?? "";
    _rewardCampaignName = appInfoSnapshot?['rewardCampaignName'] ?? "";
    _miningCampaignContents = appInfoSnapshot?['miningCampaignContents'] ?? "";
    _miningCampaignContentsAR =
        appInfoSnapshot?['miningCampaignContentsAR'] ?? "";
    _rewardCampaignContents = appInfoSnapshot?['rewardCampaignContents'] ?? "";
    _rewardCampaignContentsAR =
        appInfoSnapshot?['rewardCampaignContentsAR'] ?? "";
    _powerConsumptionHintText =
        appInfoSnapshot?['powerConsumptionHintText'] ?? "";

    bansList = appInfoSnapshot?['banned'];
    _detailsAboutYourLocationHint =
        appInfoSnapshot?['detailsAboutYourLocationHint'] ?? "";

    _signalsGroupWalletAddress =
        appInfoSnapshot?['signalsGroupWalletAddress'] ?? "";

    _employeesList = appInfoSnapshot?['Employees'];

    salesEmail = appInfoSnapshot?['salesEmail'];
    supportEmail = appInfoSnapshot?['supportEmail'];
    supportNumber = appInfoSnapshot?['supportNumber'];
    website = appInfoSnapshot?['website'];
    tiktok = appInfoSnapshot?['tiktok'];
    github = appInfoSnapshot?['github'];
    linkedIn = appInfoSnapshot?['linkedIn'];
    twitter = appInfoSnapshot?['twitter'];
    instagram = appInfoSnapshot?['instagram'];
    telegram = appInfoSnapshot?['telegram'];
    facebook = appInfoSnapshot?['facebook'];
    _signalsSupportNumber = appInfoSnapshot?['signalsSupportNumber'];

    _allowedPeopleToAddOrRemoveMiningItems =
        appInfoSnapshot?['allowedPeopleToAddOrRemoveMiningItems'];

    _allowedPeopleToAddOrRemoveRewardItems =
        appInfoSnapshot?['allowedPeopleToAddOrRemoveRewardItems'];

    salesNumber = appInfoSnapshot?['salesNumber'];
    _miningDisabledMessage =
        appInfoSnapshot?['miningDisabledMessage'] ?? "Coming Soon!";
    _miningDisabledMessageAR =
        appInfoSnapshot?['miningDisabledMessageAR'] ?? "Coming Soon!";
    _rewardsDisabledMessage =
        appInfoSnapshot?['rewardsDisabledMessage'] ?? "Coming Soon!";
    _rewardsDisabledMessageAR =
        appInfoSnapshot?['rewardsDisabledMessageAR'] ?? "Coming Soon!";

    spreadSheetScriptURL = appInfoSnapshot?['spreadSheetScriptURL'] ??
        'https://script.google.com/macros/s/AKfycbxoYd7p9NNFN4AzLX4pcEeu0my9KQR28fpWdsBK6E1rAvIQT5WhnAKnRJZAeCjLrIea/exec';

    spreadSheetID = appInfoSnapshot?['spreadSheetID'] ??
        '1_FMmquecebW5jTZalv3Ti5Wqv3bzx7nyTxMuzQdq-H8';

    largeAmountsSpreadSheetID = appInfoSnapshot?['largeAmountsSpreadSheetID'] ??
        '1vKJVTEdLZqRgiWfzdv2KekF76yAGkBeyHuZiMyw6IYY';

    forceUpdate = appInfoSnapshot?['forceUpdate'] ?? false;
    worksheetTitle = appInfoSnapshot?['worksheetTitle'] ?? 'Sheet1';

    _minableItemSearchBarHintText =
        appInfoSnapshot?['minableItemSearchBarHintText'] ?? '';
    _minableItemSearchBarHintTextAR =
        appInfoSnapshot?['minableItemSearchBarHintTextAR'] ?? '';

    _telegramPublicLink = appInfoSnapshot?['telegramPublicLink'] ?? '';
    _telegramIDBotLink = appInfoSnapshot?['telegramIDBotLink'] ?? '';
    iOSAppId = appInfoSnapshot?['iosAppID'] ?? '';
    androidAppId = appInfoSnapshot?['androidAppId'] ?? '';
    customError = appInfoSnapshot?['customError'] ?? '';
    customErrorAR = appInfoSnapshot?['customErrorAR'] ?? '';
    nextText = appInfoSnapshot?['nextText'] ?? '';
    nextTextSize = appInfoSnapshot?['nextTextSize'] ?? '';
    nextTextSizeAR = appInfoSnapshot?['nextTextSizeAR'] ?? '';
    nextTextColor = appInfoSnapshot?['nextTextColor'] ?? '';
    nextTextColorAR = appInfoSnapshot?['nextTextColorAR'] ?? '';
    nextTextAR = appInfoSnapshot?['nextTextAR'] ?? '';
    submissionTextAR = appInfoSnapshot?['submissionTextAR'] ?? '';
    submissionText = appInfoSnapshot?['submissionText'] ?? '';
    iosAppVersion = appInfoSnapshot?['iosVersion'] ?? '';
    SearchInOrdersCollectionName =
        appInfoSnapshot?['SearchInOrdersCollectionName'] ?? '';
    androidAppVersion = appInfoSnapshot?['androidVersion'] ?? '';
    smallAmountsLimit =
        num.tryParse(appInfoSnapshot?['smallAmountsLimit']) ?? 0;
    isSundayOff = appInfoSnapshot?['isSundayOff'] ?? false;
    hideImage = appInfoSnapshot?['hideImage'] ?? false;
    checkForOpeningHours = appInfoSnapshot?['checkForOpeningHours'];
    _checkForRoot = appInfoSnapshot?['checkForRoot'] ?? false;
    _showSellRate = appInfoSnapshot?['showSellRate'] ?? false;
    _hideContents = appInfoSnapshot?['hideContents'] ?? false;
    _showDeactivateAccount = appInfoSnapshot?['showDeactivateAccount'] ?? false;
    _hideDisclaimer = appInfoSnapshot?['hideDisclaimer'] ?? false;
    openMiningItemDetailsScreen =
        appInfoSnapshot?['openMiningItemDetailsScreen'] ?? false;

    isHoliday = appInfoSnapshot?['isHoliday'] ?? false;
    showCustomError = appInfoSnapshot?['showCustomError'] ?? false;
    contactUsNumber = appInfoSnapshot?['contactUsNumber'] ?? '+96171215047';
    _mainCurrency = appInfoSnapshot?['mainCurrency'] ?? 'USDT';
    weekdayOpeningHours =
        appInfoSnapshot?['weekdayWorkingHours'].toString().split('-')[0] ??
            false;
    // weekdayClosingHours =
    //     appInfoSnapshot?['weekdayWorkingHours'].toString().split('-')[1] ??
    //         false;
    weekendOpeningHours =
        appInfoSnapshot?['weekendWorkingHours'].toString().split('-')[0] ??
            false;
    // weekendClosingHours =
    //     appInfoSnapshot?['weekendWorkingHours'].toString().split('-')[1] ??
    //         false;

    minimumOrder = appInfoSnapshot?['minimumOrder'] ?? 0;
    cities = appInfoSnapshot?['cities'] ?? 0;
    refreshView();
  }
}

abstract class HomeScreenControllerView {
  void refreshState();
  void jumpToCartScreen();
}
