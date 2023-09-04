
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobUtility{

  String productionBottomBannerAdUnitId = 'ca-app-pub-1710164244221834/9253797898';
  // String developmentBottomBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  String productionCoinWinAdUnitId = 'ca-app-pub-1710164244221834/8384403504';
  // String developmentCoinWinAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  String productionRewardedAdUnitId  = 'ca-app-pub-1710164244221834/9171474207';
  // String developmentRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

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