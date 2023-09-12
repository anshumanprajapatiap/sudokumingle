
import 'package:google_mobile_ads/google_mobile_ads.dart';

String productionBottomBannerAdUnitIdGoodData = 'ca-app-pub-1710164244221834/9253797898';
String productionCoinWinAdUnitIdGoodData = 'ca-app-pub-1710164244221834/8384403504';
String productionRewardedAdUnitIdGoodData  = 'ca-app-pub-1710164244221834/9171474207';

// String developmentBottomBannerAdUnitIdGoodData = 'ca-app-pub-3940256099942544/6300978111';
// String developmentCoinWinAdUnitIdGoodData = 'ca-app-pub-3940256099942544/1033173712';
// String developmentRewardedAdUnitIdGoodData = 'ca-app-pub-3940256099942544/5224354917';


class AdMobUtility{


  String productionBottomBannerAdUnitId = productionBottomBannerAdUnitIdGoodData;
  String productionCoinWinAdUnitId = productionCoinWinAdUnitIdGoodData;
  String productionRewardedAdUnitId = productionRewardedAdUnitIdGoodData;

  BannerAd bottomBarAd(){
    BannerAd bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: productionBottomBannerAdUnitId,
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              // setState(() {
              //   _isAdLoaded = true;
              // });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              // print(error);
            }
        ),
        request: const AdRequest()
    );

    return bannerAd;
  }

  BannerAd largeBannerAd(){
    BannerAd bannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: productionBottomBannerAdUnitId,
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              // setState(() {
              //   _isAdLoaded = true;
              // });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              // print(error);
            }
        ),
        request: const AdRequest()
    );

    return bannerAd;
  }

  late InterstitialAd interstitialAd;
  InterstitialAd winCoinAd(){

    InterstitialAd.load(
        adUnitId: productionCoinWinAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad){
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