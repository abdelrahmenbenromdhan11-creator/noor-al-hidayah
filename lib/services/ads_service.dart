import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  // ═══════════════════════════════════════════════════════
  // Test Ad Unit IDs من Google (تعمل فورًا للاختبار)
  // ═══════════════════════════════════════════════════════
  static const String _testRewardedAndroid = 'ca-app-pub-7354273374998913/8374937127';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  // ⚠️ استبدل هذين المعرفين بمعرفاتك الحقيقية من AdMob لاحقًا
  static const String _realRewardedAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _realRewardedIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';

  // استخدم test في وضع التطوير
  static const bool useTestAds = false;

  static String get rewardedAdUnitId {
    if (useTestAds) {
      return _testRewardedAndroid; // يستخدم نفس ID لأندرويد و iOS أثناء الاختبار
    }
    return _realRewardedAndroid;
  }

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  // ═══════════════ تهيئة الإعلانات ═══════════════
  static Future<void> initialize() async {
    if (kIsWeb) return; // لا تعمل على المتصفح
    await MobileAds.instance.initialize();
  }

  // ═══════════════ تحميل إعلان مكافأة ═══════════════
  static Future<void> loadRewardedAd({
    required Function(int amount) onRewarded,
    required Function(String error) onError,
  }) async {
    if (kIsWeb) {
      onError('Ads not supported on web');
      return;
    }

    if (_isLoading) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _rewardedAd = ad;
          _showAd(onRewarded: onRewarded, onError: onError);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          onError(error.message);
        },
      ),
    );
  }

  static void _showAd({
    required Function(int amount) onRewarded,
    required Function(String error) onError,
  }) {
    if (_rewardedAd == null) {
      onError('Ad not loaded');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onError(error.message);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // ═══ المستخدم شاهد الإعلان كاملًا → يمنح 20 نقطة ═══
        onRewarded(reward.amount.toInt());
      },
    );
  }

  // ═══════════════ إعادة التحميل للاستخدام التالي ═══════════════
  static void reset() {
    _rewardedAd = null;
    _isLoading = false;
  }
}
