import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a score (text + optional PNG of the results board) to the platform
/// share sheet. The one thing that makes a family game travel is a parent
/// posting "we won!" in the group chat, so this must never crash the
/// results screen: every platform failure degrades to `false`.
class ShareService {
  const ShareService();

  /// Returns `true` when the share sheet was shown (whatever the user
  /// then did with it), `false` when sharing is unavailable here.
  Future<bool> shareScore({
    required String text,
    String? subject,
    Uint8List? image,
    String imageName = 'iqraquest_score.png',
    Rect? origin,
  }) async {
    if (kIsWeb && image != null) {
      // Browsers without the Web Share API silently drop files: send the
      // text alone so the call still does something visible.
      image = null;
    }
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          title: subject,
          files: image == null
              ? null
              : [XFile.fromData(image, mimeType: 'image/png', name: imageName)],
          fileNameOverrides: image == null ? null : [imageName],
          sharePositionOrigin: origin,
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (e, st) {
      debugPrint('ShareService: share failed: $e\n$st');
      return false;
    }
  }
}
