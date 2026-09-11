import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos/api/api_client.dart';

class Bet {
  final int dog1;
  final int? dog2;
  final double amount;
  final double odds;

  Bet({
    required this.dog1,
    this.dog2,
    required this.amount,
    required this.odds,
  });

  /// WINNER cuando solo hay un perro; EXACTA cuando hay 1° y 2°.
  String get betType => dog2 == null ? 'WINNER' : 'EXACTA';

  /// Formato que espera el backend: "3" para ganador, "3-5" para exacta.
  String get selection => dog2 == null ? '$dog1' : '$dog1-$dog2';
}

enum TicketStatus {
  approved,
  winner,
  loser,
  paid,
  annulled,
}

class Ticket {
  final String id;
  final int ticketNumber;
  final String dateTime;
  final List<Bet> plays;
  final double amount;
  final double investment;
  final double pay;
  final double balance;
  final String game;
  final TicketStatus status;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.dateTime,
    required this.plays,
    required this.amount,
    required this.investment,
    required this.pay,
    required this.balance,
    required this.game,
    required this.status,
  });

  /// Construye el ticket desde la respuesta del backend.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    final details = (json['details'] as List<dynamic>? ?? []);
    final plays = details.map((raw) {
      final d = Map<String, dynamic>.from(raw as Map);
      final parts = (d['selection'] as String).split('-');
      return Bet(
        dog1: int.tryParse(parts.first) ?? 0,
        dog2: parts.length > 1 ? int.tryParse(parts[1]) : null,
        amount: toDoubleValue(d['amount']),
        odds: toDoubleValue(d['odds']),
      );
    }).toList();

    final amount = toDoubleValue(json['totalAmount']);
    final prize = toDoubleValue(json['prizeAmount']);

    return Ticket(
      id: json['id'] as String? ?? '',
      ticketNumber: (json['ticketNumber'] as num?)?.toInt() ?? 0,
      dateTime: formatDateTime(json['createdAt'] as String?),
      plays: plays,
      amount: amount,
      investment: amount,
      pay: prize,
      balance: prize - amount,
      game: 'Racing Dogs',
      status: statusFrom(json['status'] as String?),
    );
  }

  static TicketStatus statusFrom(String? status) {
    switch (status) {
      case 'WON':
        return TicketStatus.winner;
      case 'LOST':
        return TicketStatus.loser;
      case 'PAID':
        return TicketStatus.paid;
      case 'CANCELLED':
        return TicketStatus.annulled;
      default:
        return TicketStatus.approved;
    }
  }
}

class RaceResult {
  final int raceNumber;
  final int winner1;
  final int winner2;
  final String bonus;

  RaceResult({
    required this.raceNumber,
    required this.winner1,
    required this.winner2,
    required this.bonus,
  });

  /// El backend guarda el resultado como "3-5-1-2-4-6-7-8"; al POS solo le
  /// interesan las dos primeras posiciones (ganador y exacta).
  factory RaceResult.fromJson(Map<String, dynamic> json) {
    final parts = (json['resultado'] as String? ?? '').split('-');
    final x2 = (json['x2Dog'] as num?)?.toInt() ?? 0;
    final x3 = (json['x3Dog'] as num?)?.toInt() ?? 0;
    return RaceResult(
      raceNumber: (json['numero'] as num?)?.toInt() ?? 0,
      winner1: parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0,
      winner2: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      bonus: x3 > 0 ? 'x3' : (x2 > 0 ? 'x2' : ''),
    );
  }
}

class RaceOdds {
  final int raceNumber;
  final List<double> odds;

  RaceOdds({
    required this.raceNumber,
    required this.odds,
  });
}

double toDoubleValue(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

String formatDateTime(String? iso) {
  final date = iso == null
      ? DateTime.now()
      : DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
}

/// Estado del POS. Todo lo que se ve en pantalla viene del backend:
/// carrera y cuenta regresiva de `/race-engine/status`, cuotas de
/// `/odds/race/{id}`, ventas de `/tickets` e historial de `/races/history`.
class PosState extends ChangeNotifier {
  PosState({ApiClient? api}) : api = api ?? ApiClient();

  final ApiClient api;

  // ─── Sesión ──────────────────────────────────────────────────────────────

  String _currentUser = '';
  String get currentUser => _currentUser;

  String _agencyId = '';
  String get agencyId => _agencyId;

  String _role = '';
  String get role => _role;

  String _agencyName = '';
  /// Nombre de la agencia del cajero, para el panel y el boleto impreso.
  String get agencyName => _agencyName;

  bool get isAuthenticated => api.isAuthenticated;

  /// Hace login contra el backend y arranca el sondeo. Devuelve `null` si
  /// entró bien, o el mensaje de error para mostrar en la pantalla de login.
  Future<String?> login(String account, String password) async {
    try {
      final result = await api.login(formatAccount(account), password);
      final user = Map<String, dynamic>.from(result['user'] as Map? ?? {});
      _currentUser = user['username'] as String? ?? account;
      _agencyId = user['agencyId'] as String? ?? '';
      _role = user['role'] as String? ?? '';

      // /users/me trae la agencia completa: de ahí sale el nombre que se
      // muestra en el panel y se imprime en el boleto.
      final me = await api.me();
      _agencyId = me['agencyId'] as String? ?? _agencyId;
      _role = me['role'] as String? ?? _role;
      _currentUser = me['username'] as String? ?? _currentUser;
      final agency = me['agency'];
      if (agency is Map) {
        _agencyName = agency['name'] as String? ?? '';
      }
      await refresh();
      start();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  void logout() {
    stop();
    api.clearToken();
    _currentUser = '';
    _agencyId = '';
    _agencyName = '';
    _role = '';
    _currentTicketPlays.clear();
    _salesHistory.clear();
    resultsHistory.clear();
    oddsHistory.clear();
    notifyListeners();
  }

  /// Agrupa los dígitos de a 3 como espera el backend: 04171826 → 041-718-26.
  static String formatAccount(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    final groups = <String>[];
    for (var i = 0; i < clean.length; i += 3) {
      final end = i + 3 > clean.length ? clean.length : i + 3;
      groups.add(clean.substring(i, end));
    }
    return groups.join('-');
  }

  // ─── Carrera en curso ────────────────────────────────────────────────────

  int _currentRace = 0;
  int get currentRace => _currentRace;

  /// Id de la carrera ABIERTA, que es contra la que se vende. Puede ser la
  /// siguiente (venta anticipada) mientras la actual reproduce su video.
  String? _sellableRaceId;
  String? get sellableRaceId => _sellableRaceId;

  int _countdownSeconds = 0;
  int get countdownSeconds => _countdownSeconds;

  bool _isServerOnline = false;
  bool get isServerOnline => _isServerOnline;

  bool _salesBlocked = false;

  /// True cuando la agencia alcanzó su límite de venta configurado.
  bool get salesBlocked => _salesBlocked;

  bool get canSell =>
      _sellableRaceId != null && !_salesBlocked && _countdownSeconds > 0;

  String? _lastError;
  String? get lastError => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  int _x2Dog = 0;
  int get x2Dog => _x2Dog;

  int _x3Dog = 0;
  int get x3Dog => _x3Dog;

  double _jackpotAmount = 0;
  double get jackpotAmount => _jackpotAmount;

  String _selectedLanguage = 'Español';
  String get selectedLanguage => _selectedLanguage;

  String _selectedPrinter = 'Impresora predeterminada';
  String get selectedPrinter => _selectedPrinter;

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setPrinter(String printer) {
    _selectedPrinter = printer;
    notifyListeners();
  }

  int? _selectedDog1;
  int? get selectedDog1 => _selectedDog1;

  int? _selectedDog2;
  int? get selectedDog2 => _selectedDog2;

  double _currentBetAmount = 0.0;
  double get currentBetAmount => _currentBetAmount;

  final List<Bet> _currentTicketPlays = [];
  List<Bet> get currentTicketPlays => _currentTicketPlays;

  final List<Ticket> _salesHistory = [];
  List<Ticket> get salesHistory => _salesHistory;

  /// Resultados e historial de cuotas: se llenan desde el backend.
  final List<RaceResult> resultsHistory = [];
  final List<RaceOdds> oddsHistory = [];

  /// Cuotas de la carrera en venta: "WINNER:3" y "EXACTA:3-5" → cuota.
  final Map<String, double> _oddsBySelection = {};

  Timer? _tickTimer;
  Timer? _pollTimer;
  bool _sending = false;
  bool get isSending => _sending;

  /// Arranca el reloj local (1s) y el sondeo al backend (cada 5s).
  void start() {
    stop();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdownSeconds > 0) {
        _countdownSeconds--;
        notifyListeners();
      }
    });
    _pollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => refreshStatus());
  }

  void stop() {
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    _tickTimer = null;
    _pollTimer = null;
  }

  /// Refresca todo: estado de carrera, ventas e historial.
  Future<void> refresh() async {
    await refreshStatus();
    await Future.wait([refreshSales(), refreshHistory()]);
  }

  /// Sondea el motor de carreras. La cuenta regresiva que manda el backend
  /// manda siempre: el reloj local solo rellena los segundos entre sondeos.
  Future<void> refreshStatus() async {
    try {
      final status = await api.raceEngineStatus();
      _isServerOnline = true;

      final current = status['currentRace'] as Map<String, dynamic>?;
      final next = status['nextRace'] as Map<String, dynamic>?;

      // Se vende contra la carrera ABIERTA: normalmente la actual, pero
      // durante el video de una carrera la venta pasa a la siguiente.
      Map<String, dynamic>? sellable;
      int? remaining;
      if (current != null && current['status'] == 'OPEN') {
        sellable = current;
        remaining = (status['remainingSaleSeconds'] as num?)?.toInt();
      } else if (next != null && next['status'] == 'OPEN') {
        sellable = next;
        remaining = (status['nextRaceRemainingSaleSeconds'] as num?)?.toInt();
      }

      final previousRaceId = _sellableRaceId;
      _sellableRaceId = sellable?['id'] as String?;
      _currentRace = (sellable?['numero'] as num?)?.toInt() ??
          (current?['numero'] as num?)?.toInt() ??
          _currentRace;
      _countdownSeconds = remaining ?? 0;
      _salesBlocked = status['salesBlocked'] as bool? ?? false;
      _x2Dog = (status['x2Dog'] as num?)?.toInt() ?? 0;
      _x3Dog = (status['x3Dog'] as num?)?.toInt() ?? 0;
      _jackpotAmount = toDoubleValue(status['jackpotAmount']);

      if (_sellableRaceId != null && _sellableRaceId != previousRaceId) {
        // Carrera nueva: cuotas nuevas y el ticket a medio armar ya no vale.
        _currentTicketPlays.clear();
        _resetSelection();
        await refreshOdds();
        unawaited(refreshHistory());
      }
      notifyListeners();
    } on ApiException catch (e) {
      _isServerOnline = false;
      _lastError = e.message;
      notifyListeners();
    }
  }

  Future<void> refreshOdds() async {
    final raceId = _sellableRaceId;
    if (raceId == null) return;
    try {
      final rows = await api.raceOdds(raceId);
      _oddsBySelection.clear();
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        _oddsBySelection['${row['betType']}:${row['selection']}'] =
            toDoubleValue(row['odds']);
      }

      // La pantalla de Cuotas muestra las cuotas de GANAR por perro.
      final winners = List<double>.generate(
        8,
        (i) => _oddsBySelection['WINNER:${i + 1}'] ?? 0.0,
      );
      oddsHistory
        ..removeWhere((o) => o.raceNumber == _currentRace)
        ..insert(0, RaceOdds(raceNumber: _currentRace, odds: winners));
      notifyListeners();
    } on ApiException catch (e) {
      _lastError = e.message;
    }
  }

  Future<void> refreshSales() async {
    try {
      final rows = await api.tickets();
      _salesHistory
        ..clear()
        ..addAll(rows.map(
            (raw) => Ticket.fromJson(Map<String, dynamic>.from(raw as Map))));
      notifyListeners();
    } on ApiException catch (e) {
      _lastError = e.message;
    }
  }

  Future<void> refreshHistory() async {
    try {
      final rows = await api.raceHistory(
        limit: 20,
        agencyId: _agencyId.isEmpty ? null : _agencyId,
      );
      resultsHistory
        ..clear()
        ..addAll(rows
            .map((raw) =>
                RaceResult.fromJson(Map<String, dynamic>.from(raw as Map)))
            .where((r) => r.winner1 > 0));
      notifyListeners();
      await _loadRecentOdds(rows);
    } on ApiException catch (e) {
      _lastError = e.message;
    }
  }

  /// Trae las cuotas de las últimas carreras terminadas para que la pantalla
  /// de Cuotas tenga historial desde el primer momento, no solo la carrera en
  /// venta. Se limita a unas pocas para no disparar decenas de peticiones.
  Future<void> _loadRecentOdds(List<dynamic> races) async {
    for (final raw in races.take(6)) {
      final race = Map<String, dynamic>.from(raw as Map);
      final id = race['id'] as String?;
      final numero = (race['numero'] as num?)?.toInt();
      if (id == null || numero == null) continue;
      if (oddsHistory.any((o) => o.raceNumber == numero)) continue;
      try {
        final rows = await api.raceOdds(id);
        final winners = List<double>.filled(8, 0.0);
        for (final rawRow in rows) {
          final row = Map<String, dynamic>.from(rawRow as Map);
          if (row['betType'] != 'WINNER') continue;
          final dog = int.tryParse(row['selection'] as String? ?? '');
          if (dog != null && dog >= 1 && dog <= 8) {
            winners[dog - 1] = toDoubleValue(row['odds']);
          }
        }
        oddsHistory.add(RaceOdds(raceNumber: numero, odds: winners));
      } on ApiException {
        // Una carrera sin cuotas no debe tumbar el historial completo.
        continue;
      }
    }
    oddsHistory.sort((a, b) => b.raceNumber.compareTo(a.raceNumber));
    notifyListeners();
  }

  // ─── Cuotas ──────────────────────────────────────────────────────────────

  double _oddsFor(String betType, String selection) =>
      _oddsBySelection['$betType:$selection'] ?? 0.0;

  /// Cuota de GANAR del perro, tal como la publica el backend.
  double getGanarOdds(int dog) => _round(_oddsFor('WINNER', '$dog'));

  /// Cuota de EXACTA del perro. Si ya hay un perro elegido para la otra
  /// posición, muestra la cuota real de ESA combinación; si no, la del par
  /// con el siguiente perro, solo como referencia de vitrina.
  double getExactaOdds(int dog) {
    if (_selectedDog1 != null && _selectedDog1 != dog) {
      return _round(_oddsFor('EXACTA', '$_selectedDog1-$dog'));
    }
    if (_selectedDog2 != null && _selectedDog2 != dog) {
      return _round(_oddsFor('EXACTA', '$dog-$_selectedDog2'));
    }
    final other = dog % 8 + 1;
    return _round(_oddsFor('EXACTA', '$dog-$other'));
  }

  double _round(double value) => double.parse(value.toStringAsFixed(2));

  // ─── Selección y armado del ticket ───────────────────────────────────────

  void selectDog1(int dogNumber) {
    if (_selectedDog1 == dogNumber) {
      _selectedDog1 = null;
    } else {
      _selectedDog1 = dogNumber;
      if (_selectedDog2 == dogNumber) _selectedDog2 = null;
    }
    notifyListeners();
    if ((_selectedDog1 != null || _selectedDog2 != null) &&
        _currentBetAmount > 0) {
      addPlayToTicket();
    }
  }

  void selectDog2(int dogNumber) {
    if (_selectedDog2 == dogNumber) {
      _selectedDog2 = null;
    } else {
      _selectedDog2 = dogNumber;
      if (_selectedDog1 == dogNumber) _selectedDog1 = null;
    }
    notifyListeners();
    if ((_selectedDog1 != null || _selectedDog2 != null) &&
        _currentBetAmount > 0) {
      addPlayToTicket();
    }
  }

  void addBetAmount(double amount) {
    _currentBetAmount += amount;
    notifyListeners();
    if ((_selectedDog1 != null || _selectedDog2 != null) &&
        _currentBetAmount > 0) {
      addPlayToTicket();
    }
  }

  void clearBetAmount() {
    _currentBetAmount = 0.0;
    notifyListeners();
  }

  void _addCalculatedPlay(int dog1, int dog2, double amount) {
    _currentTicketPlays.add(Bet(
      dog1: dog1,
      dog2: dog2,
      amount: amount,
      odds: _oddsFor('EXACTA', '$dog1-$dog2'),
    ));
  }

  void _addSinglePlay(int dog, double amount) {
    _currentTicketPlays.add(Bet(
      dog1: dog,
      dog2: null,
      amount: amount,
      odds: _oddsFor('WINNER', '$dog'),
    ));
  }

  void _resetSelection() {
    _selectedDog1 = null;
    _selectedDog2 = null;
    _currentBetAmount = 0.0;
  }

  void playReverse() {
    if (_selectedDog1 != null &&
        _selectedDog2 != null &&
        _currentBetAmount > 0) {
      _addCalculatedPlay(_selectedDog1!, _selectedDog2!, _currentBetAmount);
      _addCalculatedPlay(_selectedDog2!, _selectedDog1!, _currentBetAmount);
      _resetSelection();
      notifyListeners();
    }
  }

  void playAllCombinations() {
    final dog = _selectedDog1 ?? _selectedDog2;
    if (dog == null || _currentBetAmount <= 0) return;

    for (int other = 1; other <= 8; other++) {
      if (other == dog) continue;
      _addCalculatedPlay(dog, other, _currentBetAmount);
    }
    _resetSelection();
    notifyListeners();
  }

  void playR() {
    final dog = _selectedDog1 ?? _selectedDog2;
    if (dog == null) return;
    _playCombinedR(dog, 25.0);
  }

  void playR2() {
    final dog = _selectedDog1 ?? _selectedDog2;
    if (dog == null) return;
    _playCombinedR(dog, 12.5);
  }

  void _playCombinedR(int dog, double amountPerPlay) {
    for (int other = 1; other <= 8; other++) {
      if (other == dog) continue;
      _addCalculatedPlay(dog, other, amountPerPlay);
      _addCalculatedPlay(other, dog, amountPerPlay);
    }
    _resetSelection();
    notifyListeners();
  }

  void addPlayToTicket() {
    if (_currentBetAmount <= 0) return;
    if (_selectedDog1 != null && _selectedDog2 != null) {
      _addCalculatedPlay(_selectedDog1!, _selectedDog2!, _currentBetAmount);
    } else if (_selectedDog1 != null) {
      _addSinglePlay(_selectedDog1!, _currentBetAmount);
    } else if (_selectedDog2 != null) {
      _addSinglePlay(_selectedDog2!, _currentBetAmount);
    } else {
      return;
    }
    _resetSelection();
    notifyListeners();
  }

  Ticket? findTicketByNumber(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;
    for (final ticket in _salesHistory) {
      if (ticket.id.toUpperCase() == trimmed.toUpperCase() ||
          ticket.ticketNumber.toString() == trimmed) {
        return ticket;
      }
    }
    return null;
  }

  /// Recarga las jugadas de un ticket al ticket en curso, con las cuotas
  /// VIGENTES (no las del ticket viejo, que ya no aplican a esta carrera).
  void repeatTicket(Ticket ticket) {
    for (final play in ticket.plays) {
      if (play.dog2 == null) {
        _addSinglePlay(play.dog1, play.amount);
      } else {
        _addCalculatedPlay(play.dog1, play.dog2!, play.amount);
      }
    }
    notifyListeners();
  }

  void deletePlayAtIndex(int index) {
    if (index >= 0 && index < _currentTicketPlays.length) {
      _currentTicketPlays.removeAt(index);
      notifyListeners();
    }
  }

  double get currentTicketTotal {
    return _currentTicketPlays.fold(0.0, (sum, play) => sum + play.amount);
  }

  void deleteCurrentTicket() {
    _currentTicketPlays.clear();
    _selectedDog1 = null;
    _selectedDog2 = null;
    _currentBetAmount = 0.0;
    notifyListeners();
  }

  /// Vende el ticket contra el backend. La cuota final la congela el servidor;
  /// si algo falla (venta cerrada, límite de la agencia, premio sobre el tope)
  /// el ticket NO se pierde: queda armado para reintentar o corregir.
  Future<String?> printTicket() async {
    if (_sending) return null;

    if (_currentTicketPlays.isEmpty &&
        (_selectedDog1 != null || _selectedDog2 != null) &&
        _currentBetAmount > 0) {
      addPlayToTicket();
    }
    if (_currentTicketPlays.isEmpty) return null;

    final raceId = _sellableRaceId;
    if (raceId == null) {
      _lastError = 'No hay una carrera abierta para vender';
      notifyListeners();
      return _lastError;
    }

    _sending = true;
    notifyListeners();
    try {
      final ticket = await api.createTicket(
        raceId: raceId,
        details: _currentTicketPlays
            .map((play) => {
                  'betType': play.betType,
                  'selection': play.selection,
                  'amount': play.amount.toStringAsFixed(2),
                })
            .toList(),
      );
      _salesHistory.insert(0, Ticket.fromJson(ticket));
      _currentTicketPlays.clear();
      _resetSelection();
      _lastError = null;
      return null;
    } on ApiException catch (e) {
      _lastError = e.message;
      return e.message;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  // ─── Totales de la pantalla de Ventas ────────────────────────────────────

  double get totalMonto => _salesHistory.fold(0.0, (sum, t) => sum + t.amount);
  double get totalInversion =>
      _salesHistory.fold(0.0, (sum, t) => sum + t.investment);
  double get totalPagar => _salesHistory.fold(0.0, (sum, t) => sum + t.pay);
  double get totalBalance =>
      _salesHistory.fold(0.0, (sum, t) => sum + t.balance);

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
