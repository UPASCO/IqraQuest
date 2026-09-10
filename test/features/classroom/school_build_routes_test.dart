// Ce que le sous-domaine des écoles sert, et ce qu'il ne sert pas.
//
// `school.iqraquest.org` et l'application des familles sont le même
// binaire Flutter. Sans garde-fou, l'adresse donnée aux écoles servait
// aussi `#/home`, `#/premium` et le jeu entier — signalé sur la vraie
// adresse, pas trouvé ici.
//
// Ce n'est pas une fuite de données : rien de ce qui compte n'est
// lisible sans se connecter, et le serveur refuse tout à la clé
// publique. C'est une question de surface — une école qui cherche sa
// console ne doit pas tomber sur un écran d'achat.
//
// Deux garde-fous, et ce fichier vérifie les deux :
//   1. les routes du jeu ne sont pas construites dans un binaire
//      d'école ;
//   2. une adresse tapée à la main y est renvoyée sur la console.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/build_flags.dart';
import 'package:iqraquest/app/router.dart';

void main() {
  test('le drapeau est éteint par défaut', () {
    // Le binaire des familles n'est jamais un binaire d'école : le
    // garde-fou est le compilateur, pas un réglage qu'on peut trouver.
    expect(kSchoolBuild, isFalse);
  });

  test('une adresse tapée à la main ramène à la console', () {
    // C'est exactement ce qui a été signalé : `#/home` répondait sur le
    // sous-domaine des écoles.
    for (final typed in [
      '/home',
      '/premium',
      '/game',
      '/settings',
      '/progress',
      '/daily-challenge',
      '/',
      '/nimporte-quoi',
    ]) {
      expect(
        schoolRedirectForTest(typed),
        '/teacher',
        reason: '$typed ne doit pas répondre sur le sous-domaine des écoles',
      );
    }
  });

  test('les routes de la classe passent sans redirection', () {
    for (final kept in [
      '/teacher',
      '/classroom',
      '/classroom?code=G4KEPW',
      '/classroom/board/G4KEPW',
    ]) {
      expect(schoolRedirectForTest(kept), isNull, reason: kept);
    }
  });

  test('un préfixe qui ressemble ne suffit pas', () {
    // `/classroomiscool` commence par `/classroom` sans être une route
    // de classe : la comparaison porte sur les segments, pas sur le
    // texte.
    expect(schoolRedirectForTest('/classroom-bis'), '/teacher');
    expect(schoolRedirectForTest('/teacherx'), '/teacher');
  });

  test('les routes du jeu ne sont pas construites dans un binaire d\'école', () {
    // Lu dans la source plutôt que mimé par une liste : une copie de la
    // table des routes divergerait de la vraie le jour où on en ajoute
    // une, et ce test dirait alors le contraire de la vérité.
    final source = File('lib/app/router.dart').readAsStringSync();
    final guard = source.indexOf('if (!kSchoolBuild) ...[');
    expect(guard, greaterThan(-1), reason: 'le garde-fou a disparu');
    final guarded = source.substring(guard, source.indexOf('],', guard));
    for (final path in [
      '/home',
      '/premium',
      '/game',
      '/onboarding',
      '/settings',
      '/progress',
      '/daily-challenge',
      '/tutorial',
      '/mode-selection',
      '/results',
    ]) {
      expect(
        guarded,
        contains("'$path'"),
        reason: '$path doit rester derrière le garde-fou',
      );
    }
  });
}
