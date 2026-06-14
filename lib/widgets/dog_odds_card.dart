import 'package:flutter/material.dart';

class DogOddsCard extends StatefulWidget {
  final int number;
  final String name;
  final String color;
  final double ganarOdds;
  final double exactaOdds;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback? onTap;
  final double width;

  const DogOddsCard({
    super.key,
    required this.number,
    required this.name,
    required this.color,
    required this.ganarOdds,
    required this.exactaOdds,
    this.isSelected = false,
    this.isDimmed = false,
    this.onTap,
    this.width = 180,
  });

  @override
  State<DogOddsCard> createState() => _DogOddsCardState();
}

class _DogOddsCardState extends State<DogOddsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0;
    if (widget.isDimmed && !widget.isSelected) {
      opacity = 0.3;
    }

    final s = widget.width / 180;

    final card = Opacity(
      opacity: opacity,
      child: Container(
        width: widget.width,
        padding: EdgeInsets.all(10 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected ? const Color(0xFFD4AF37) : Colors.white24,
            width: widget.isSelected ? 2.5 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Number badge + name/color
            Row(
              children: [
                Image.asset(
                  'assets/resources/botonnumero${widget.number}.png',
                  height: 58 * s,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: 'DinNextLtPro',
                          color: Colors.white,
                          fontSize: 16 * s,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.color,
                        style: TextStyle(
                          fontFamily: 'DinNextLtPro',
                          color: Colors.white60,
                          fontSize: 12 * s,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * s),
            // Dog photo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/resources/dog_${widget.number}.png',
                height: 90 * s,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8 * s),
            // Odds rows
            _oddsRow('GANAR', widget.ganarOdds, s),
            SizedBox(height: 4 * s),
            _oddsRow('EXACTA', widget.exactaOdds, s),
          ],
        ),
      ),
    );

    if (widget.onTap == null) {
      return card;
    }

    return Semantics(
      label: 'Perro ${widget.number} ${widget.name}',
      button: true,
      selected: widget.isSelected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: card,
          ),
        ),
      ),
    );
  }

  Widget _oddsRow(String label, double value, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DinNextLtPro',
              color: const Color(0xFFD4AF37),
              fontSize: 13 * s,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontFamily: 'DinNextLtPro',
              color: Colors.white,
              fontSize: 13 * s,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
