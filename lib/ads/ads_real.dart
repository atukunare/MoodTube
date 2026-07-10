// Android/iOS ad implementation (google_mobile_ads + UMP consent).
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moodtube/theme/tokens.dart';

// Real native ad unit (used in release builds). In debug we use Google's test
// native ad unit so you never risk a self-click ban while developing.
const String _realNativeAdUnitId = 'ca-app-pub-9993388177095923/4949636004';
const String _testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
const String _nativeAdUnitId =
    kReleaseMode ? _realNativeAdUnitId : _testNativeAdUnitId;

bool _adsInitialized = false;

Future<void> initAds() async {
  await _requestConsentThenInit();
}

Future<void> _ensureMobileAdsInitialized() async {
  if (_adsInitialized) return;
  try {
    await MobileAds.instance.initialize();
    _adsInitialized = true;
  } catch (_) {}
}

/// GDPR/UMP consent form, then Mobile Ads init. Failures are swallowed so ads
/// never block app launch.
Future<void> _requestConsentThenInit() async {
  try {
    final completerDone = <bool>[false];
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          }
        } catch (_) {}
        await _ensureMobileAdsInitialized();
        completerDone[0] = true;
      },
      (FormError error) async {
        await _ensureMobileAdsInitialized();
        completerDone[0] = true;
      },
    );
    // Bound wait so launch is never blocked by a hung consent callback.
    for (var i = 0; i < 40 && !completerDone[0]; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await _ensureMobileAdsInitialized();
  } catch (_) {
    await _ensureMobileAdsInitialized();
  }
}

Widget smartPickAd() => const _NativeAdSlot();

Widget resultsListAd() => const _NativeAdSlot();

class _NativeAdSlot extends StatefulWidget {
  const _NativeAdSlot();

  @override
  State<_NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<_NativeAdSlot> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final dark = DesignTokens.isDark;
    final ad = NativeAd(
      adUnitId: _nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
      // Built-in template (no native Android layout needed).
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor:
            dark ? const Color(0xff211c33) : const Color(0xffffffff),
        cornerRadius: 20,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: dark ? const Color(0xfff4f1fc) : const Color(0xff171926),
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: dark ? const Color(0xff9b95b6) : const Color(0xff737b91),
          size: 13,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xff9b7cff),
          size: 14,
        ),
      ),
    )..load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    // AnimatedSize opens the slot smoothly when the ad loads instead of
    // shoving 110px into the list in a single frame.
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: (ad == null || !_loaded)
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 110, // small native template
              child: AdWidget(ad: ad),
            ),
    );
  }
}
