import 'dart:convert';
import 'package:http/http.dart' as http;

/// Error de API con el mensaje que devuelve el backend (NestJS manda
/// `message` como string o como lista de errores de validación).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Cliente HTTP del POS contra el backend de MBSport DS8.
///
/// La URL base se puede cambiar al compilar sin tocar código:
///   flutter run -d windows --dart-define=API_BASE_URL=http://localhost:3000
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.ds8.site',
  );

  static const Duration _timeout = Duration(seconds: 15);

  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  void setToken(String? token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    late http.Response response;
    try {
      response = await request().timeout(_timeout);
    } catch (e) {
      throw ApiException('No hay conexión con el servidor');
    }

    if (response.statusCode == 401) {
      throw ApiException('Sesión expirada o credenciales inválidas', 401);
    }

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
    }

    if (response.statusCode >= 400) {
      throw ApiException(_messageOf(body) ?? 'Error ${response.statusCode}', response.statusCode);
    }

    return body;
  }

  /// NestJS devuelve `message` como texto o como lista (errores de validación).
  String? _messageOf(dynamic body) {
    if (body is! Map) return null;
    final message = body['message'];
    if (message is String) return message;
    if (message is List && message.isNotEmpty) return message.join('\n');
    return null;
  }

  Future<dynamic> _get(String path, [Map<String, String>? query]) =>
      _send(() => http.get(_uri(path, query), headers: _headers));

  Future<dynamic> _post(String path, [Object? body]) => _send(
        () => http.post(
          _uri(path),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        ),
      );

  // ─── Auth ────────────────────────────────────────────────────────────────

  /// `username` va en formato XXX-XXX-XX (8 dígitos) o XXX-XXX-XXX-XXX (12).
  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await _post('/auth/login', {
      'username': username,
      'password': password,
    });
    final map = Map<String, dynamic>.from(result as Map);
    final token = map['accessToken'] as String?;
    if (token == null) throw ApiException('El servidor no devolvió un token');
    _token = token;
    return map;
  }

  Future<Map<String, dynamic>> me() async =>
      Map<String, dynamic>.from(await _get('/users/me') as Map);

  // ─── Carreras y cuotas ───────────────────────────────────────────────────

  /// Estado del motor: carrera en curso, próxima, cuenta regresiva de venta,
  /// jackpots, X2/X3 y límite de venta de la agencia.
  Future<Map<String, dynamic>> raceEngineStatus() async =>
      Map<String, dynamic>.from(await _get('/race-engine/status') as Map);

  /// Matriz completa de cuotas de una carrera (WINNER y EXACTA).
  Future<List<dynamic>> raceOdds(String raceId) async =>
      (await _get('/odds/race/$raceId')) as List<dynamic>;

  /// Historial de carreras terminadas. Con `agencyId` devuelve el resultado
  /// que realmente vio esa agencia (puede diferir del global por Target Hold).
  Future<List<dynamic>> raceHistory({int limit = 20, String? agencyId}) async =>
      (await _get('/races/history', {
        'limit': '$limit',
        if (agencyId != null) 'agencyId': agencyId,
      })) as List<dynamic>;

  // ─── Tickets ─────────────────────────────────────────────────────────────

  /// Crea el ticket. La cuota la congela el backend desde su matriz: lo que
  /// mande el cliente se ignora, por eso solo se envían tipo, selección y monto.
  Future<Map<String, dynamic>> createTicket({
    required String raceId,
    required List<Map<String, String>> details,
  }) async =>
      Map<String, dynamic>.from(
        await _post('/tickets', {'raceId': raceId, 'details': details}) as Map,
      );

  Future<List<dynamic>> tickets() async => (await _get('/tickets')) as List<dynamic>;

  Future<Map<String, dynamic>> cancelTicket(String ticketId, {String? reason, String? code}) async =>
      Map<String, dynamic>.from(
        await _post('/tickets/$ticketId/cancel', {
          if (reason != null) 'reason': reason,
          if (code != null) 'code': code,
        }) as Map,
      );
}
