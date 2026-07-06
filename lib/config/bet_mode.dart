/// Modo de apuestas de esta build, fijado en tiempo de compilación:
///
///   flutter build windows --dart-define=BET_MODE=exacta
///
/// Por defecto (sin la bandera) la build incluye TRIFECTA completa. Con
/// BET_MODE=exacta se compila la variante que solo vende GANADOR y EXACTA
/// (sin fila de 3er lugar ni nada relacionado a tripleta).
const bool kTrifectaEnabled =
    String.fromEnvironment('BET_MODE', defaultValue: 'trifecta') != 'exacta';
