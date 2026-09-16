// Le « tour des cartes gratuites » : ce que l'appareil retient des
// cartes vues, et le moment où il peut dire qu'il les a toutes vues.
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('les cartes vues s\'accumulent, sans doublon, et survivent au rechargement', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final progress = ProgressService(storage);
    expect(progress.seenQuestionIds(), isEmpty);
    await progress.markSeen(['q1', 'q2']);
    await progress.markSeen(['q2', 'q3']);
    expect(ProgressService(storage).seenQuestionIds(), {'q1', 'q2', 'q3'});
  });

  test('le tour est fait quand chaque carte gratuite a été vue au moins une fois', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressService(await LocalStorageService.create());
    const free = {'f1', 'f2', 'f3'};
    expect(progress.freeTourDone(free), isFalse);
    await progress.markSeen(['f1', 'f2', 'p9']);
    expect(progress.freeTourDone(free), isFalse, reason: 'f3 jamais vue');
    await progress.markSeen(['f3']);
    expect(progress.freeTourDone(free), isTrue);
    expect(progress.freeTourDone(const {}), isFalse, reason: 'sans cartes gratuites, rien à annoncer');
  });
}
