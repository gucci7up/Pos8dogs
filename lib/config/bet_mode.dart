/// Modo de apuestas de esta build, fijado en tiempo de compilación.
///
/// DS8 (8 perros) solo vende GANADOR y EXACTA: el backend ni siquiera tiene
/// el tipo TRIFECTA, así que el valor por defecto aquí es la variante exacta
/// —al revés que en la build de 6 perros—. La bandera se conserva por si
/// alguna vez se quiere compilar con tripleta:
///
///   flutter build windows --dart-define=BET_MODE=trifecta
const bool kTrifectaEnabled =
    String.fromEnvironment('BET_MODE', defaultValue: 'exacta') == 'trifecta';
