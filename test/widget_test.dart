import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos/config/bet_mode.dart';
import 'package:pos/config/dogs.dart';

void main() {
  group('Configuración de la build DS8', () {
    test('la carrera es de 8 perros', () {
      expect(kDogCount, 8);
    });

    test('cada perro tiene nombre y color, sin huecos', () {
      for (var dog = 1; dog <= kDogCount; dog++) {
        final info = kDogInfo[dog];
        expect(info, isNotNull, reason: 'falta el perro $dog');
        expect(info!['name'], isNotEmpty);
        expect(info['color'], isNotEmpty);
      }
      expect(kDogInfo.length, kDogCount);
    });

    test('todos los perros tienen color de barra propio', () {
      final colors = <int, Color>{};
      for (var dog = 1; dog <= kDogCount; dog++) {
        colors[dog] = dogColor(dog);
      }
      expect(colors.length, kDogCount);
      expect(colors[7], isNot(Colors.grey),
          reason: 'el 7 debe tener color propio, no el de respaldo');
      expect(colors[8], isNot(Colors.grey),
          reason: 'el 8 debe tener color propio, no el de respaldo');
    });

    test('los perros de dos tonos se dibujan a rayas', () {
      expect(isStripedDog(6), isTrue);
      expect(isStripedDog(8), isTrue);
      expect(isStripedDog(1), isFalse);
      expect(stripedColors(8).length, 5);
    });

    test('DS8 vende solo GANADOR y EXACTA: sin tripleta', () {
      // El backend de 8 perros no tiene el tipo TRIFECTA, así que una build
      // por defecto con tripleta activa vendería algo que el servidor rechaza.
      expect(kTrifectaEnabled, isFalse);
    });
  });
}
