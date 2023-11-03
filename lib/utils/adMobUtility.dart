import 'package:google_mobile_ads/google_mobile_ads.dart';

String productionBottomBannerAdUnitIdGoodData =
    'ca-app-pub-1710164244221834/4902429199';
String productionCoinWinAdUnitIdGoodData =
    'ca-app-pub-1710164244221834/5716021256';
String productionRewardedAdUnitIdGoodData =
    'ca-app-pub-1710164244221834/4402939587';

// String developmentBottomBannerAdUnitIdGoodData = 'ca-app-pub-3940256099942544/6300978111';
// String developmentCoinWinAdUnitIdGoodData = 'ca-app-pub-3940256099942544/1033173712';
// String developmentRewardedAdUnitIdGoodData = 'ca-app-pub-3940256099942544/5224354917';

const int maxFailedLoadAttempts = 3;

class AdMobUtility {
  String productionBottomBannerAdUnitId =
      'ca-app-pub-1710164244221834/4902429199';
  String productionCoinWinAdUnitId = 'ca-app-pub-1710164244221834/5716021256';
  String productionRewardedAdUnitId = 'ca-app-pub-1710164244221834/4402939587';

  BannerAd bottomBarAd() {
    // MobileAds.instance.updateRequestConfiguration(
    //     RequestConfiguration(testDeviceIds: [testDevice]));
    int _numBannerAdLoadAttempts = 0;
    BannerAd bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: productionBottomBannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (ad) {
          // setState(() {
          //   _isAdLoaded = true;
          // });
        }, onAdFailedToLoad: (ad, error) {
          // ad.dispose();
          print('bottomBarAd failed to load: $error.');
        }),
        request: const AdRequest());

    return bannerAd;
  }

  BannerAd largeBannerAd() {
    // 7351ad45-e905-4847-9d87-cb9a538d95d6
    // MobileAds.instance.updateRequestConfiguration(
    //     RequestConfiguration(testDeviceIds: [testDevice]));
    int _numLargeBannerAdLoadAttempts = 0;
    print('addId: $productionBottomBannerAdUnitId');
    BannerAd bannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: productionBottomBannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (ad) {
          // setState(() {
          //   _isAdLoaded = true;
          // });
        }, onAdFailedToLoad: (ad, error) {
          print('LargeBannerAd failed to load: $error.');
          _numLargeBannerAdLoadAttempts += 1;
          if (_numLargeBannerAdLoadAttempts < maxFailedLoadAttempts) {
            largeBannerAd();
          }
        }),
        request: const AdRequest());

    return bannerAd;
  }

  late InterstitialAd interstitialAd;
  InterstitialAd winCoinAd() {
    InterstitialAd.load(
      adUnitId: productionCoinWinAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: ((error) {
          interstitialAd.dispose();
        }),
      ),
    );
    return interstitialAd;
  }
}
