import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/env.dart';
import '../../features/auth/presentation/viewmodel/auth_session.dart';

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authSessionProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        if (session.isAuthed) {
          o.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        // ignore: avoid_print
        print('➡️ ${o.method} ${o.baseUrl}${o.path}  data=${o.data}');
        h.next(o);
      },
      onResponse: (r, h) {
        // ignore: avoid_print
        print('✅ ${r.statusCode} ${r.requestOptions.path}  data=${r.data}');
        h.next(r);
      },
      onError: (e, h) {
        // ignore: avoid_print
        print('❌ ${e.response?.statusCode} ${e.requestOptions.path}');
        // ignore: avoid_print
        print('❌ message=${e.message}');
        // ignore: avoid_print
        print('❌ data=${e.response?.data}');
        h.next(e);
      },
    ),
  );

  return dio;
});