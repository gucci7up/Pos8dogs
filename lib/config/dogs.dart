import 'package:flutter/material.dart';

/// Cantidad de perros por carrera. Es la ÚNICA diferencia de reglas entre
/// esta build (DS8) y la de 6 perros: todo lo que recorre perros usa esta
/// constante en vez de un número suelto.
const int kDogCount = 8;

/// Nombre y color de cada perro, tal como se muestran en las tarjetas.
const Map<int, Map<String, String>> kDogInfo = {
  1: {'name': 'BRAVO', 'color': 'ROJO'},
  2: {'name': 'RELAMPAGO', 'color': 'AZUL'},
  3: {'name': 'TIGRE', 'color': 'BLANCO'},
  4: {'name': 'NEGRO', 'color': 'NEGRO'},
  5: {'name': 'FURIA', 'color': 'NARANJA'},
  6: {'name': 'BANDIDO', 'color': 'BLANCO/NEGRO'},
  7: {'name': 'KIKI', 'color': 'VERDE'},
  8: {'name': 'RAYMUNDO', 'color': 'NARANJA/NEGRO'},
};

/// Color sólido del perro para las barras de la tabla de cuotas.
Color dogColor(int dog) {
  switch (dog) {
    case 1:
      return const Color(0xFFE02020);
    case 2:
      return const Color(0xFF2255CC);
    case 3:
      return const Color(0xFFFFFFFF);
    case 4:
      return const Color(0xFF444444);
    case 5:
      return const Color(0xFFFF7A00);
    case 6:
      return const Color(0xFFCCCCCC);
    case 7:
      return const Color(0xFF2E9E4F);
    case 8:
      return const Color(0xFFFF7A00);
    default:
      return Colors.grey;
  }
}

/// Perros de dos tonos: se dibujan con degradado a rayas en vez de color
/// plano (6 = blanco/negro, 8 = naranja/negro).
bool isStripedDog(int dog) => dog == 6 || dog == 8;

/// Colores del degradado a rayas de los perros de dos tonos.
List<Color> stripedColors(int dog) {
  final base = dog == 8 ? const Color(0xFFFF7A00) : const Color(0xFFFFFFFF);
  const dark = Color(0xFF333333);
  return [base, dark, base, dark, base];
}
