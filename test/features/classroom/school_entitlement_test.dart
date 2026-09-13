// Le contrat commercial du mode École, joué contre le double en mémoire
// qui applique les mêmes règles que `open_session` en SQL.
//
// Chaque test ici correspond à une ligne du cahier des charges :
//   partie 1..5 = OK, partie 6 = quota ;
//   licence active → partie 6, 7… = OK ;
//   appareil A, B = OK, C = limite ; A meurt, C = OK ;
//   la même demande rejouée = la même séance, un seul crédit ;
//   abonnement fini + quota vide = rien ne s'ouvre.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/classroom/application/teacher_console_controller.dart';
import 'package:iqraquest/features/classroom/data/fake_classroom_gateway.dart';
import 'package:iqraquest/features/classroom/data/fake_teacher_gateway.dart';
import 'package:iqraquest/features/classroom/data/teacher_gateway.dart';
import 'package:iqraquest/features/classroom/domain/lesson.dart';
import 'package:iqraquest/models/question_category.dart';

/// Un compte découverte : cinq parties, deux salles, pas d'échéance.
Licence discovery({int used = 0}) => Licence(
  id: 'l1',
  email: 'ecole@example.org',
  plan: 'decouverte',
  concurrentSessions: 2,
  expiresAt: DateTime(2126),
  freeGames: 5,
  freeGamesUsed: used,
);

/// Une licence École : deux salles, un an, sans quota.
Licence school({Duration life = const Duration(days: 365), String status = 'active'}) =>
    Licence(
      id: 'l2',
      email: 'ecole@example.org',
      plan: 'ecole',
      concurrentSessions: 2,
      expiresAt: DateTime.now().add(life),
      status: status,
    );

Lesson lesson() => const Lesson(
  id: 'lesson_prophets_beginner_01',
  category: QuestionCategory.prophets,
  difficulty: QuestionDifficulty.beginner,
  index: 1,
  questionIds: ['q1', 'q2', 'q3'],
);

({FakeTeacherGateway gateway, FakeClassroomGateway room}) harness({
  Licence? licence,
  DateTime Function()? clock,
}) {
  final room = FakeClassroomGateway(random: Random(3), clock: clock);
  final gateway = FakeTeacherGateway(
    room: room,
    licence: licence,
    signedInAs: 'ecole@example.org',
    clock: clock,
  );
  return (gateway: gateway, room: room);
}

Future<Object?> tryOpen(TeacherGateway g, {String? requestId}) async {
  try {
    return await g.openSession(
      lessonId: lesson().id,
      questionIds: lesson().questionIds,
      requestId: requestId,
    );
  } on TeacherException catch (e) {
    return e.error;
  }
}

void main() {
  group('les cinq parties offertes', () {
    test('cinq s\'ouvrent, la sixième demande une licence', () async {
      final h = harness(licence: discovery());
      for (var i = 1; i <= 5; i++) {
        final r = await tryOpen(h.gateway);
        expect(r, isA<({String sessionId, String code})>(), reason: 'partie $i');
        // Chaque partie est fermée avant la suivante : on teste le quota,
        // pas la limite d'appareils.
        await h.gateway.advance((r as ({String sessionId, String code})).sessionId, TeacherAction.close);
      }
      final sixth = await tryOpen(h.gateway);
      expect(sixth, TeacherError.quotaExhausted);
      final account = await h.gateway.account();
      expect(account.freeGamesUsed, 5);
      expect(account.freeGamesLeft, 0);
      expect(account.state, AccountState.quotaExhausted);
      expect(account.canStart, isFalse);
      expect(account.blocker, StartBlocker.quota);
    });

    test('le compteur vit sur le serveur : il ne se remet pas à zéro', () async {
      // Un autre appareil, même compte : le compteur est celui de la
      // licence, pas du navigateur.
      final h = harness(licence: discovery(used: 4));
      expect(await tryOpen(h.gateway), isA<({String sessionId, String code})>());
      expect(await tryOpen(h.gateway), TeacherError.quotaExhausted);
    });

    test('la licence École lève le quota : sixième, septième…', () async {
      final h = harness(licence: school());
      for (var i = 6; i <= 12; i++) {
        final r = await tryOpen(h.gateway);
        expect(r, isA<({String sessionId, String code})>(), reason: 'partie $i');
        await h.gateway.advance((r as ({String sessionId, String code})).sessionId, TeacherAction.close);
      }
      final account = await h.gateway.account();
      expect(account.free, isFalse);
      expect(account.canStart, isTrue);
    });
  });

  group('deux appareils à la fois', () {
    test('A et B jouent, C est refusé ; A meurt, C entre', () async {
      var now = DateTime(2026, 9, 13, 10);
      final h = harness(licence: school(), clock: () => now);

      final a = await tryOpen(h.gateway) as ({String sessionId, String code});
      final b = await tryOpen(h.gateway) as ({String sessionId, String code});
      expect(a.code, isNot(b.code));

      expect(await tryOpen(h.gateway), TeacherError.tooManySessions,
          reason: 'la troisième tablette est refusée tant qu\'une place n\'est pas libre');
      final account = await h.gateway.account();
      expect(account.roomsInUse, 2);
      expect(account.blocker, StartBlocker.sessions);

      // A donne signe de vie ; B a planté et se tait.
      now = now.add(const Duration(minutes: 4));
      await h.gateway.heartbeat(a.sessionId);
      now = now.add(const Duration(minutes: 2));
      // B n'a rien dit depuis six minutes : au-delà du bail, sa place est
      // libre sans qu'on ait eu à la fermer.
      expect(await tryOpen(h.gateway), isA<({String sessionId, String code})>(),
          reason: 'le bail de B a expiré, C entre');
      final sessions = await h.gateway.sessions();
      expect(sessions.where((s) => s.alive).length, 2);
      expect(sessions.firstWhere((s) => s.sessionId == b.sessionId).alive, isFalse);
    });

    test('fermer une séance libère sa place tout de suite', () async {
      final h = harness(licence: school());
      final a = await tryOpen(h.gateway) as ({String sessionId, String code});
      await tryOpen(h.gateway);
      expect(await tryOpen(h.gateway), TeacherError.tooManySessions);
      await h.gateway.advance(a.sessionId, TeacherAction.close);
      expect(await tryOpen(h.gateway), isA<({String sessionId, String code})>());
    });
  });

  group('rejeu et concurrence', () {
    test('la même demande rejouée rend la même séance et un seul crédit', () async {
      final h = harness(licence: discovery(used: 4));
      final first = await tryOpen(h.gateway, requestId: 'req-1') as ({String sessionId, String code});
      final again = await tryOpen(h.gateway, requestId: 'req-1') as ({String sessionId, String code});
      expect(again.sessionId, first.sessionId);
      expect(again.code, first.code);
      final account = await h.gateway.account();
      expect(account.freeGamesUsed, 5, reason: 'un seul crédit consommé');
    });

    test('deux appareils sur le dernier crédit : un seul passe', () async {
      final h = harness(licence: discovery(used: 4));
      final results = await Future.wait([
        tryOpen(h.gateway, requestId: 'a'),
        tryOpen(h.gateway, requestId: 'b'),
      ]);
      final opened = results.whereType<({String sessionId, String code})>().length;
      final refused = results.where((r) => r == TeacherError.quotaExhausted).length;
      expect(opened, 1);
      expect(refused, 1);
    });
  });

  group('l\'abonnement', () {
    test('fini et quota vide : rien ne s\'ouvre, l\'espace reste', () async {
      final h = harness(licence: school(life: const Duration(days: -1)));
      expect(await tryOpen(h.gateway), TeacherError.licenceExpired);
      final account = await h.gateway.account();
      expect(account.state, AccountState.expired);
      expect(account.locked, isTrue);
      // L'historique se lit encore : l'école n'a rien perdu.
      expect(await h.gateway.reports(), isA<List<SessionReport>>());
    });

    test('un paiement en défaut ferme la prochaine séance, pas la courante', () async {
      final h = harness(licence: school());
      final a = await tryOpen(h.gateway) as ({String sessionId, String code});
      h.gateway.grant(school(status: 'unpaid'));
      expect(await tryOpen(h.gateway), TeacherError.licenceExpired);
      // La séance ouverte avant l'incident se termine normalement.
      await h.gateway.advance(a.sessionId, TeacherAction.reveal);
      await h.gateway.advance(a.sessionId, TeacherAction.close);
    });

    test('renouvellement annulé : actif jusqu\'à l\'échéance', () async {
      final h = harness(licence: school(status: 'canceled', life: const Duration(days: 30)));
      expect(await tryOpen(h.gateway), isA<({String sessionId, String code})>());
    });
  });

  group('le contrôleur', () {
    test('bat toutes les 60 s tant que la séance est ouverte', () async {
      var now = DateTime(2026, 9, 13, 10);
      final h = harness(licence: school(), clock: () => now);
      final c = TeacherConsoleController(
        h.gateway,
        heartbeatEvery: const Duration(milliseconds: 20),
      );
      await c.start();
      await c.openSession(lesson: lesson());
      final id = c.state.sessionId!;
      now = now.add(const Duration(minutes: 3));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(h.gateway.lastSeen[id], now, reason: 'le battement a rafraîchi le bail');
      await c.endSession();
      expect(h.gateway.lastSeen.containsKey(id), isFalse);
      c.dispose();
    });

    test('supprimer le compte efface la licence et déconnecte', () async {
      final h = harness(licence: discovery());
      final c = TeacherConsoleController(h.gateway);
      await c.start();
      await c.deleteAccount();
      expect(h.gateway.deleted, isTrue);
      expect(c.state.stage, ConsoleStage.signedOut);
      c.dispose();
    });
  });
}
