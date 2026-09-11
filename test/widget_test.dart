import 'package:flutter_test/flutter_test.dart';
import 'package:pos/state/pos_state.dart';

void main() {
  test('formatAccount agrupa los digitos de a 3 como espera el backend', () {
    expect(PosState.formatAccount('04171826'), '041-718-26');
    expect(PosState.formatAccount('041718261234'), '041-718-261-234');
  });

  test('Bet traduce la jugada al contrato de la API', () {
    final winner = Bet(dog1: 3, amount: 25, odds: 4.5);
    expect(winner.betType, 'WINNER');
    expect(winner.selection, '3');

    final exacta = Bet(dog1: 3, dog2: 5, amount: 25, odds: 30.0);
    expect(exacta.betType, 'EXACTA');
    expect(exacta.selection, '3-5');
  });

  test('RaceResult toma solo las dos primeras posiciones del resultado', () {
    final result = RaceResult.fromJson({
      'numero': 12,
      'resultado': '3-5-1-2-4-6-7-8',
      'x2Dog': 4,
    });
    expect(result.raceNumber, 12);
    expect(result.winner1, 3);
    expect(result.winner2, 5);
    expect(result.bonus, 'x2');
  });

  test('Ticket.fromJson mapea detalles, estado y balance', () {
    final ticket = Ticket.fromJson({
      'id': 'abc',
      'ticketNumber': 1042,
      'status': 'WON',
      'totalAmount': '50.00',
      'prizeAmount': '120.00',
      'createdAt': '2026-09-10T15:04:05.000Z',
      'details': [
        {'betType': 'EXACTA', 'selection': '3-5', 'amount': '50.00', 'odds': '2.40'},
      ],
    });
    expect(ticket.ticketNumber, 1042);
    expect(ticket.status, TicketStatus.winner);
    expect(ticket.plays.single.dog1, 3);
    expect(ticket.plays.single.dog2, 5);
    expect(ticket.balance, 70.0);
  });
}
