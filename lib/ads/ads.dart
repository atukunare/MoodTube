// Public ad API. Uses a conditional import so the web build never pulls in
// google_mobile_ads (which is Android/iOS only) — web gets the no-op stub.
import 'package:flutter/widgets.dart';

import 'ads_stub.dart' if (dart.library.io) 'ads_real.dart' as impl;

/// Initialize the ads SDK (no-op on web / unsupported platforms).
Future<void> initAds() => impl.initAds();

/// An ad slot to drop into the Smart Picks list. Renders nothing until/unless
/// an ad actually loads (and always nothing on web).
Widget smartPickAd() => impl.smartPickAd();
