import 'package:flutter/material.dart';

class RaceInfoPanel extends StatelessWidget {
  final int raceNumber;
  final int countdownSeconds;
  final String nextRaceStartLabel;
  final String raceStatusLabel;
  final int x2Dog;
  final int x3Dog;
  final double jackpotAmount;
  final double jackpotMega;
  final double exactaBonusPool;
  final String bonusExacta;
  final bool salesLimitEnabled;
  final double salesRemaining;
  final double salesLimit;
  final bool salesBlocked;

  const RaceInfoPanel({
    super.key,
    required this.raceNumber,
    required this.countdownSeconds,
    required this.nextRaceStartLabel,
    required this.raceStatusLabel,
    this.x2Dog = 0,
    this.x3Dog = 0,
    this.jackpotAmount = 0.0,
    this.jackpotMega = 0.0,
    this.exactaBonusPool = 0.0,
    this.bonusExacta = '',
    this.salesLimitEnabled = false,
    this.salesRemaining = 0.0,
    this.salesLimit = 0.0,
    this.salesBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (countdownSeconds / 240.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Carrera Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CARRERA',
                style: TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$raceNumber',
                style: const TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 45),

          // Empieza Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EMPIEZA',
                style: TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                nextRaceStartLabel,
                style: const TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 35),

          // Activo / Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ACTIVO',
                style: TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Color(0xFFB0A261),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                raceStatusLabel,
                style: const TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 45),

          // Countdown Timer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/resources/reloj_icon.png',
                width: 22,
                height: 22,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SEG',
                    style: TextStyle(
                      fontFamily: 'DinNextLtPro',
                      color: Color(0xFF9E9E9E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$countdownSeconds',
                    style: const TextStyle(
                      fontFamily: 'DinNextLtPro',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 15),

          // Red Progress Bar
          Container(
            width: 200,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Jackpot BIG
          _PotCounter(label: 'JACKPOT BIG', amount: jackpotAmount, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 20),
          // Jackpot MEGA
          _PotCounter(label: 'MEGA', amount: jackpotMega, color: const Color(0xFF7E57C2)),
          const SizedBox(width: 20),
          // Bonus Exacta (pozo)
          _PotCounter(label: 'BONUS', amount: exactaBonusPool, color: const Color(0xFF26A69A)),

          // Badge de la exacta sorteada esta carrera
          if (bonusExacta.isNotEmpty) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Color(0xFF26A69A), blurRadius: 6, spreadRadius: 1)],
              ),
              child: Text(
                'BONUS $bonusExacta',
                style: const TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          // Cuadro de SALDO DISPONIBLE — cuenta en descenso hacia cero
          if (salesLimitEnabled) ...[
            const SizedBox(width: 24),
            _SaldoBox(
              remaining: salesRemaining,
              limit: salesLimit,
              blocked: salesBlocked,
            ),
          ],

          // Multiplicador X3 (rojo) o X2 (naranja) — excluyentes por carrera.
          // Solo visible cuando la carrera está cerrada/corriendo.
          if (x3Dog > 0) ...[
            const SizedBox(width: 20),
            _MultiplierBadge(label: 'X3', dog: x3Dog, color: const Color(0xFFE53935)),
          ] else if (x2Dog > 0) ...[
            const SizedBox(width: 20),
            _MultiplierBadge(label: 'X2', dog: x2Dog, color: const Color(0xFFFF6B35)),
          ],
        ],
      ),
    );
  }
}

/// Contador de un pozo (jackpot BIG/MEGA o bonus) para el header.
class _PotCounter extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _PotCounter({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DinNextLtPro',
            color: Color(0xFFB0A261),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'DinNextLtPro',
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Badge de multiplicador (X2 naranja / X3 rojo) que anuncia el perro con
/// cuota aumentada esta carrera.
class _MultiplierBadge extends StatelessWidget {
  final String label;
  final int dog;
  final Color color;

  const _MultiplierBadge({required this.label, required this.dog, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: color, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DinNextLtPro',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Perro $dog',
            style: const TextStyle(
              fontFamily: 'DinNextLtPro',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuadro de "SALDO DISPONIBLE": muestra el efectivo restante antes de que el
/// POS se bloquee, contando en descenso desde el límite hacia cero, con una
/// barra de progreso y color según qué tan bajo esté el saldo.
class _SaldoBox extends StatelessWidget {
  final double remaining;
  final double limit;
  final bool blocked;

  const _SaldoBox({
    required this.remaining,
    required this.limit,
    required this.blocked,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = limit > 0 ? (remaining / limit).clamp(0.0, 1.0) : 0.0;
    final Color color = blocked
        ? const Color(0xFFFF5252)
        : ratio <= 0.15
            ? const Color(0xFFFF5252)
            : ratio <= 0.40
                ? const Color(0xFFFFB300)
                : const Color(0xFF4CAF50);

    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10231A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                blocked ? 'POS BLOQUEADO' : 'SALDO DISPONIBLE',
                style: TextStyle(
                  fontFamily: 'DinNextLtPro',
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              if (limit > 0)
                Text(
                  'de \$${limit.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'DinNextLtPro',
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '\$${remaining.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'DinNextLtPro',
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
