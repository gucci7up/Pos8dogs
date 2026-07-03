import 'package:flutter/material.dart';
import 'package:pos/widgets/dog_button.dart';
import 'package:pos/state/pos_state.dart';

class CuotasScreen extends StatefulWidget {
  final PosState state;
  const CuotasScreen({super.key, required this.state});

  @override
  State<CuotasScreen> createState() => _CuotasScreenState();
}

class _CuotasScreenState extends State<CuotasScreen> {
  // Máx/mín de cada mercado, para colorear la más alta (rojo) y la más baja (verde)
  double _exMax = 0, _exMin = 0, _ganMax = 0, _ganMin = 0;

  Color _dogColor(int dog) {
    switch (dog) {
      case 1: return const Color(0xFFE02020);
      case 2: return const Color(0xFF2255CC);
      case 3: return const Color(0xFFFFFFFF);
      case 4: return const Color(0xFF444444);
      case 5: return const Color(0xFFFF7A00);
      case 6: return const Color(0xFFCCCCCC);
      default: return Colors.grey;
    }
  }

  // Color relativo: la cuota que MÁS paga (más alta) en rojo, la que MENOS paga
  // (más baja) en verde; el resto en blanco.
  Color _oddsRelColor(double odds, double maxOdds, double minOdds) {
    if (odds <= 0) return Colors.white24;
    if (maxOdds > minOdds) {
      if (odds >= maxOdds) return const Color(0xFFFF5252); // más paga → rojo
      if (odds <= minOdds) return const Color(0xFF4CD964); // menos paga → verde
    }
    return Colors.white;
  }

  Widget _hBar(int dog) {
    if (dog == 6) {
      return Container(
        height: 3,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF333333),
              Color(0xFFFFFFFF),
              Color(0xFF333333),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
      );
    }
    return Container(height: 3, color: _dogColor(dog));
  }

  Widget _vBar(int dog) {
    if (dog == 6) {
      return Container(
        width: 4,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF333333),
              Color(0xFFFFFFFF),
              Color(0xFF333333),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
      );
    }
    return Container(width: 4, color: _dogColor(dog));
  }

  Widget _buildCell(int dog1, int dog2) {
    if (dog1 == dog2) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    final odds = widget.state.getExactaOddsPair(dog1, dog2);
    final text = odds > 0 ? odds.toStringAsFixed(2) : '—';
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'DinNextLtPro',
            color: _oddsRelColor(odds, _exMax, _exMin),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Máx/mín de EXACTA (todas las parejas válidas) y de GANADOR (6 perros)
    double exMax = 0, exMin = double.infinity;
    for (int a = 1; a <= 6; a++) {
      for (int b = 1; b <= 6; b++) {
        if (a == b) continue;
        final o = widget.state.getExactaOddsPair(a, b);
        if (o > 0) { if (o > exMax) exMax = o; if (o < exMin) exMin = o; }
      }
    }
    double ganMax = 0, ganMin = double.infinity;
    for (int d = 1; d <= 6; d++) {
      final o = widget.state.getGanarOdds(d);
      if (o > 0) { if (o > ganMax) ganMax = o; if (o < ganMin) ganMin = o; }
    }
    _exMax = exMax; _exMin = exMin == double.infinity ? 0 : exMin;
    _ganMax = ganMax; _ganMin = ganMin == double.infinity ? 0 : ganMin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
      child: Column(
        children: [
          // ── Matríz EXACTA ──────────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Label "PRIMERO" rotado
                SizedBox(
                  width: 26,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: const Text(
                        'PRIMERO',
                        style: TextStyle(
                          fontFamily: 'DinNextLtPro',
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      // Fila de cabecera: "EXACTA" + "SEGUNDO"
                      SizedBox(
                        height: 36,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 82,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'EXACTA',
                                  style: TextStyle(
                                    fontFamily: 'DinNextLtPro',
                                    color: Color(0xFFD4AF37),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
                                  ),
                                ),
                                child: const Text(
                                  'SEGUNDO',
                                  style: TextStyle(
                                    fontFamily: 'DinNextLtPro',
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cabeceras de columna
                      SizedBox(
                        height: 60,
                        child: Row(
                          children: [
                            const SizedBox(width: 82),
                            ...List.generate(6, (i) {
                              final dog = i + 1;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DogButton(number: dog, height: 34),
                                      const SizedBox(height: 4),
                                      _hBar(dog),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      // Grilla de datos
                      Expanded(
                        child: Column(
                          children: List.generate(6, (rowIdx) {
                            final dog1 = rowIdx + 1;
                            return Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 82,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _vBar(dog1),
                                        const SizedBox(width: 6),
                                        Expanded(child: Center(child: DogButton(number: dog1, height: 40))),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(6, (colIdx) => Expanded(child: _buildCell(dog1, colIdx + 1))),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Barra GANADOR ───────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label GANADOR
                SizedBox(
                  width: 90,
                  child: Center(
                    child: const Text(
                      'GANADOR',
                      style: TextStyle(
                        fontFamily: 'DinNextLtPro',
                        color: Color(0xFFD4AF37),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                // 6 cards de perro + cuota ganador
                ...List.generate(6, (i) {
                  final dog = i + 1;
                  final odds = widget.state.getGanarOdds(dog);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _dogColor(dog).withOpacity(0.4), width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DogButton(number: dog, height: 34),
                            const SizedBox(height: 4),
                            Text(
                              odds > 0 ? odds.toStringAsFixed(2) : '—',
                              style: TextStyle(
                                fontFamily: 'DinNextLtPro',
                                color: _oddsRelColor(odds, _ganMax, _ganMin),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
