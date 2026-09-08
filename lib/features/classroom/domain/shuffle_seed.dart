/// A seed that survives a restart.
///
/// The answers on a screen are shuffled per device, and that shuffle has
/// to be reproducible: a projector whose page is refreshed mid-question,
/// or a pupil's phone that comes back after the wifi dropped, must find
/// the four answers exactly where the room last saw them. Moving them
/// under a child's finger would be cruel, and on the wall it would make
/// the class doubt what they had just read.
///
/// `Object.hash` cannot do this: Dart mixes a per-isolate random seed
/// into string hashes, so the same words hash differently after a
/// restart. This is a plain FNV-1a over the parts, which does not.
int stableSeed(List<Object?> parts) {
  var hash = 0x811c9dc5;
  for (final part in parts) {
    for (final unit in '$part '.codeUnits) {
      hash ^= unit;
      // FNV prime, kept inside 32 bits so the web and the phone agree.
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
  }
  return hash;
}
