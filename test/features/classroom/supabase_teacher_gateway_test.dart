// The teacher's line to the server: a link to an address, then a token
// on every call. What is checked here is that nothing but that address
// identifies a teacher, and that an expired hour never throws one out
// in front of a class.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iqraquest/features/classroom/data/supabase_teacher_gateway.dart';
import 'package:iqraquest/features/classroom/data/teacher_gateway.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _url = 'https://example.supabase.co';
const _anon = 'anon-key';

Future<LocalStorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues({});
  return LocalStorageService.create();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the sign-in link goes to the address, and nowhere else', () async {
    final calls = <({Uri url, Map<String, dynamic> body})>[];
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      redirectTo: 'https://iqraquest.example/teacher-callback.html',
      client: MockClient((request) async {
        calls.add((
          url: request.url,
          body: jsonDecode(request.body) as Map<String, dynamic>,
        ));
        return http.Response('{}', 200);
      }),
    );

    await gateway.sendMagicLink('  ecole@example.org ');

    expect(calls.single.url.path, '/auth/v1/otp');
    expect(calls.single.body['email'], 'ecole@example.org');
    expect(calls.single.body['create_user'], true);
    // The return address travels as a query parameter: GoTrue reads
    // `redirect_to` there and ignores anything put in the body, which is
    // exactly how the link used to come back to the wrong page.
    expect(
      calls.single.url.queryParameters['redirect_to'],
      'https://iqraquest.example/teacher-callback.html',
    );
  });

  test('with no callback configured, the link carries no redirect', () async {
    Uri? seen;
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient((request) async {
        seen = request.url;
        return http.Response('{}', 200);
      }),
    );

    await gateway.sendMagicLink('ecole@example.org');

    expect(seen!.queryParameters, isEmpty);
    expect(seen!.path, '/auth/v1/otp');
  });

  test('an address that is not one never reaches the server', () async {
    var called = false;
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      gateway.sendMagicLink('ecole'),
      throwsA(
        isA<TeacherException>().having(
          (e) => e.error,
          'error',
          TeacherError.invalidEmail,
        ),
      ),
    );
    expect(called, isFalse);
  });

  test('the tokens a magic link leaves behind are read, in both shapes', () {
    expect(
      sessionFromFragment('access_token=abc&refresh_token=def')?.accessToken,
      'abc',
    );
    expect(
      sessionFromFragment('/teacher?access_token=abc&refresh_token=def')
          ?.refreshToken,
      'def',
      reason: 'the hash-routed build hands the pair over after a ?',
    );
    expect(sessionFromFragment(''), isNull);
    expect(sessionFromFragment('/teacher'), isNull);
    expect(sessionFromFragment('access_token=abc'), isNull);
  });

  test('a link signs the teacher in, and the seat outlives a reload', () async {
    final storage = await freshStorage();
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: storage,
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    final signedIn = await gateway.restore(
      fragment: 'access_token=abc&refresh_token=def',
    );

    expect(signedIn, isTrue);
    expect(gateway.isSignedIn, isTrue);
    expect(
      storage.getJson('iqraquest.teacher.session.v1')?['refresh_token'],
      'def',
    );
  });

  test('a kept seat is traded for a fresh token on the next visit', () async {
    final storage = await freshStorage();
    await storage.setJson('iqraquest.teacher.session.v1', {
      'access_token': 'old',
      'refresh_token': 'keep',
      'email': 'ecole@example.org',
    });
    final paths = <String>[];
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: storage,
      client: MockClient((request) async {
        paths.add(request.url.path);
        return http.Response(
          jsonEncode({
            'access_token': 'new',
            'refresh_token': 'keep2',
            'user': {'email': 'ecole@example.org'},
          }),
          200,
        );
      }),
    );

    expect(await gateway.restore(fragment: ''), isTrue);
    expect(paths.single, '/auth/v1/token');
    expect(gateway.email, 'ecole@example.org');
  });

  test('a teacher who was never signed in is told so, not left waiting', () async {
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(await gateway.restore(fragment: ''), isFalse);
    await expectLater(
      gateway.licence(),
      throwsA(
        isA<TeacherException>().having(
          (e) => e.error,
          'error',
          TeacherError.notSignedIn,
        ),
      ),
    );
  });

  test('every call carries the teacher token, not the anonymous key', () async {
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient((request) async {
        if (request.url.path.endsWith('my_licence')) {
          expect(request.headers['Authorization'], 'Bearer abc');
          return http.Response(
            jsonEncode({
              'id': 'l1',
              'email': 'ecole@example.org',
              'plan': 'classe',
              'concurrent_sessions': 3,
              'expires_at': DateTime.now()
                  .add(const Duration(days: 30))
                  .toIso8601String(),
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      }),
    );
    await gateway.restore(fragment: 'access_token=abc&refresh_token=def');

    final licence = await gateway.licence();

    expect(licence!.concurrentSessions, 3);
    expect(licence.isValid, isTrue);
  });

  test('an hour that ran out is renewed rather than shown to the class', () async {
    final calls = <String>[];
    var refreshed = false;
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient((request) async {
        calls.add(request.url.path);
        if (request.url.path == '/auth/v1/token') {
          refreshed = true;
          return http.Response(
            jsonEncode({'access_token': 'fresh', 'refresh_token': 'def2'}),
            200,
          );
        }
        if (!refreshed) return http.Response('{}', 401);
        return http.Response(
          jsonEncode({'sessionId': 's1', 'code': 'G4KEPW'}),
          200,
        );
      }),
    );
    await gateway.restore(fragment: 'access_token=abc&refresh_token=def');

    final opened = await gateway.openSession(
      lessonId: 'lesson_sira_beginner_01',
      questionIds: const ['sira_001'],
    );

    expect(opened.code, 'G4KEPW');
    expect(calls, contains('/auth/v1/token'));
  });

  test('what the functions refuse is said in a teacher\'s own terms', () async {
    for (final entry in {
      'no_licence': TeacherError.noLicence,
      'licence_expired': TeacherError.licenceExpired,
      'no_questions': TeacherError.noQuestions,
      'unknown_session': TeacherError.unknownSession,
      'not_now': TeacherError.notNow,
    }.entries) {
      final gateway = SupabaseTeacherGateway(
        url: _url,
        anonKey: _anon,
        storage: await freshStorage(),
        client: MockClient(
          (_) async => http.Response(jsonEncode({'error': entry.key}), 200),
        ),
      );
      await gateway.restore(fragment: 'access_token=abc&refresh_token=def');

      await expectLater(
        gateway.openSession(lessonId: 'l', questionIds: const ['q']),
        throwsA(
          isA<TeacherException>().having((e) => e.error, entry.key, entry.value),
        ),
      );
    }
  });

  test('a licence already running its rooms says how many it has', () async {
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: await freshStorage(),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'too_many_sessions', 'limit': 4}),
          200,
        ),
      ),
    );
    await gateway.restore(fragment: 'access_token=abc&refresh_token=def');

    await expectLater(
      gateway.openSession(lessonId: 'l', questionIds: const ['q']),
      throwsA(isA<TeacherException>().having((e) => e.limit, 'limit', 4)),
    );
  });

  test('signing out leaves nothing behind on the machine', () async {
    final storage = await freshStorage();
    final gateway = SupabaseTeacherGateway(
      url: _url,
      anonKey: _anon,
      storage: storage,
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    await gateway.restore(fragment: 'access_token=abc&refresh_token=def');

    await gateway.signOut();

    expect(gateway.isSignedIn, isFalse);
    expect(storage.getJson('iqraquest.teacher.session.v1'), isNull);
  });
}
