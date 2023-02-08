import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

export 'package:firebase_dynamic_links/firebase_dynamic_links.dart'
    show SocialMetaTagParameters;

typedef OnNewDynamicLinkPath = void Function(String newDynamicLinkPath);

/// Wrapper around [FirebaseDynamicLinks].
class DynamicLinkService {
  // TODO: Create a constant to hold your dynamic link prefix.
  // static const _domainUriPrefix = 'https://wonderwords1.page.link';
  static const _domainUriPrefix = 'https://raywenderlich2315.page.link';
  static const _iOSBundleId = 'com.raywenderlich.wonderWords';
  static const _androidPackageName = 'com.raywenderlich.wonder_words';

  DynamicLinkService({
    @visibleForTesting FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  final FirebaseDynamicLinks _dynamicLinks;

  // TODO: Create a function that generates dynamic links

  Future<String> generateDynamicLinkUrl(
      {required String path,
      SocialMetaTagParameters? socialMetaTagParameters}) async {
    final parameters = DynamicLinkParameters(
      link: Uri.parse('$_domainUriPrefix$path'),
      uriPrefix: _domainUriPrefix,
      androidParameters:
          const AndroidParameters(packageName: _androidPackageName),
      iosParameters: const IOSParameters(
        bundleId: _iOSBundleId,
      ),
    );

    final shortLink = await _dynamicLinks.buildShortLink(parameters);

    return shortLink.shortUrl.toString();
  }
// Future<String> generateDynamicLinkUrl({
//   required String path,
//   SocialMetaTagParameters? socialMetaTagParameters,
// }) async {
//   final parameters = DynamicLinkParameters(
//     uriPrefix: _domainUriPrefix,
//     link: Uri.parse(
//       '$_domainUriPrefix$path',
//     ),
//     androidParameters: const AndroidParameters(
//       packageName: _androidPackageName,
//     ),
//     iosParameters: const IOSParameters(
//       bundleId: _iOSBundleId,
//     ),
//     socialMetaTagParameters: socialMetaTagParameters,
//   );
//
//   final shortLink = await _dynamicLinks.buildShortLink(parameters);
//   return shortLink.shortUrl.toString();
// }

// TODO: Create a function that returns the link that launched the app.

// Future<String?> getInitialDynamicLinkPath() async {
//   final data = await _dynamicLinks.getInitialLink();
//   final link = data?.link;
//   return link?.path;
// }

// TODO: Expose a way to listen to new links.
// Stream<String> onNewDynamicLinkPath() {
//   return _dynamicLinks.onLink.map(
//     (PendingDynamicLinkData data) {
//       final link = data.link;
//       final path = link.path;
//       return path;
//     },
//   );
// }
}
