import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  final Random _random = Random();

  // Official Google AdMob Test Banner Unit ID for Android
  final String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Official Google AdMob test unit IDs for full-screen ads
  String get _testInterstitialUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return 'ca-app-pub-3940256099942544/4411468910';
  }

  String get _testRewardedUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    return 'ca-app-pub-3940256099942544/1712485313';
  }

  @override
  void initState() {
    super.initState();
    _loadRealTestAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadRealTestAd() {
    _bannerAd = BannerAd(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // Sets standard 320x50 click boundaries
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          debugPrint('Google AdMob Live Server Handshake: Success.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Google AdMob Live Server Handshake: Failed: $error');
        },
        // Trigger a random full-screen test ad when the banner is clicked/opened.
        onAdOpened: (ad) {
          debugPrint('User successfully interacted with the Test Ad!');
          _showRandomFullScreenAd();
        },
      ),
    )..load(); // Dispatches the asynchronous network thread fetch
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _testInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          debugPrint('Interstitial failed to load: $error');
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _testRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  void _showRandomFullScreenAd() {
    final bool showInterstitial = _random.nextBool();

    if (showInterstitial && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          debugPrint('Interstitial failed to show: $error');
        },
      );
      _interstitialAd!.show();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          debugPrint('Rewarded ad failed to show: $error');
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('Reward earned: ${reward.amount} ${reward.type}');
        },
      );
      return;
    }

    // If neither ad is ready yet, start loading them for the next click.
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // Wipes memory reference to avoid resource leaks
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ IF THE AD LOADED, RETURN GOOGLE'S REAL INTERACTIVE WIDGET
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: AdWidget(
          ad: _bannerAd!,
        ), // 🧠 Google's actual clickable engine view
      );
    }

    // Smooth loading fallback spinner while communicating with Google servers
    return const SizedBox(
      height: 50,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      ),
    );
  }
}
