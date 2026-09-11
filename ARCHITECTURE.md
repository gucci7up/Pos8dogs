# ARCHITECTURE.md

Documento de arquitectura del proyecto **POS "Racing Dogs"**, una aplicación Flutter de escritorio (kiosko POS) para venta de apuestas de carreras de galgos. Toda la interfaz está en español y diseñada sobre un lienzo fijo de **1920x1080**.

---

## 1. Estructura de carpetas

```
lib/
├── main.dart                  # Punto de entrada, configuración de ventana y switch de pantallas
├── state/
│   └── pos_state.dart         # Estado global (modelos + ChangeNotifier)
├── layouts/
│   ├── desktop_layout.dart    # Shell externo: canvas fijo 1920x1080 escalado con FittedBox
│   └── main_layout.dart       # Header compartido (tabs, panel derecho, info de carrera)
├── screens/
│   ├── jugada_screen.dart      # Pantalla principal de apuestas (tab 0)
│   ├── resultados_screen.dart  # Histórico de resultados (tab 1)
│   ├── cuotas_screen.dart       # Tabla de cuotas/odds (tab 2)
│   └── ventas_screen.dart       # Historial de tickets/ventas (tab 3)
└── widgets/
    ├── dog_button.dart         # Botón/ícono de número de perro (reutilizado en varias pantallas)
    ├── action_button.dart      # Botón genérico de acción con fondo de imagen
    ├── amount_button.dart      # Botón de monto rápido (25/50/100/200)
    ├── race_info_panel.dart    # Panel de info de carrera + countdown
    ├── right_panel.dart        # Logo, ID de terminal y botón de configuración
    └── top_navigation.dart     # Barra de pestañas superior

assets/
├── fonts/                      # Fuente custom DinNextLtPro
└── resources/                  # Todos los PNG/JPEG usados como fondos de botones, iconos, logos
```

No existen carpetas `services/`, `repositories/`, `models/` separadas ni cliente HTTP — todo el modelo de datos vive dentro de `state/pos_state.dart`.

---

## 2. Pantallas

La app tiene **4 pantallas**, todas reciben la instancia única de `PosState` por constructor y se intercambian mediante un `switch` en `main.dart`:

| Índice | Pantalla | Archivo | Descripción |
|--------|----------|---------|-------------|
| 0 | **JUGADA** | `jugada_screen.dart` | Pantalla principal de apuestas. Selección de perros para 1° y 2° lugar, montos rápidos, panel de ticket deslizable (drawer) con las jugadas actuales, y botones de borrar/imprimir ticket. |
| 1 | **RESULTADOS** | `resultados_screen.dart` | Tabla con histórico de resultados (`resultsHistory`): número de carrera, perros ganadores (1°/2°) y bonus. Incluye 3 botones de impresión (solo feedback visual vía `SnackBar`, sin lógica real). |
| 2 | **CUOTAS** | `cuotas_screen.dart` | Tabla de cuotas por carrera (`oddsHistory`): una fila por carrera con las cuotas de los 8 perros. Incluye 3 botones de impresión (5/10/20, también solo `SnackBar`). |
| 3 | **VENTAS** | `ventas_screen.dart` | Tabla del historial de tickets emitidos (`salesHistory`) con columnas Nu., Fecha/Hora, Jugadas, Monto, Inversión, Pagar, Balance, Juego y Estado (icono según `TicketStatus`). Incluye barra resumen amarilla con totales y botón "BALANCE" (también solo `SnackBar`). |

Cada pantalla es un `StatefulWidget` que recibe `state: PosState` y mantiene su propio estado local de UI (hovers, drawer abierto/cerrado, etc.), pero **toda la lógica de negocio y los datos viven en `PosState`**.

---

## 3. Navegación

La navegación **no usa rutas** (`Navigator`, `MaterialPageRoute`, named routes, etc.). Es un simple **índice de pestaña** controlado por estado local:

- `main.dart` → `_MainScreenState` mantiene `int _currentTabIndex` (0-3).
- `MainLayout` recibe `currentTabIndex` y `onTabChanged` y los pasa a `TopNavigation` (`widgets/top_navigation.dart`).
- `TopNavigation` dibuja las 4 pestañas (`JUGADA`, `RESULTADOS`, `CUOTAS`, `VENTAS`) y al hacer tap invoca `onTabChanged(index)`.
- `_MainScreenState.build()` hace un `switch` sobre `_currentTabIndex` para decidir qué `Widget activeScreen` renderizar dentro de `MainLayout`.

```
RacingDogsApp (MaterialApp)
└── MainScreen (StatefulWidget, contiene PosState y _currentTabIndex)
    └── ListenableBuilder(listenable: PosState)
        └── MainLayout(currentTabIndex, onTabChanged, state, child: activeScreen)
            └── DesktopLayout (canvas fijo 1920x1080)
                ├── Header: TopNavigation + RightPanel + RaceInfoPanel
                └── activeScreen (Jugada / Resultados / Cuotas / Ventas)
```

`DesktopLayout` (`layouts/desktop_layout.dart`) envuelve todo en un `Scaffold` + `FittedBox` que fuerza un `SizedBox(1920x1080)`, escalado para llenar la ventana real — por eso toda la UI usa tamaños absolutos en píxeles pensados para ese lienzo.

---

## 4. Estado global

Toda la lógica de negocio y los datos están centralizados en **`lib/state/pos_state.dart`**, en la clase `PosState extends ChangeNotifier`. No se usa ningún paquete de gestión de estado (sin `provider`, `riverpod`, `bloc`); la propagación de cambios es manual:

- `MainScreen` crea **una sola instancia** de `PosState` en `initState()` y la destruye en `dispose()`.
- Se distribuye por **constructor** a todas las pantallas (`state: _state`).
- `MainScreen` se reconstruye completo mediante `ListenableBuilder(listenable: _state, ...)`.
- Algunas pantallas (p. ej. `JugadaScreen`) además llaman `state.addListener(...)` manualmente para reaccionar a cambios específicos (ver sección de flujo de apuestas).

### Modelos de datos (definidos en el mismo archivo)

- **`Bet`**: una jugada individual — `dog1`, `dog2`, `amount`, `odds`.
- **`Ticket`**: un ticket impreso — `id`, `ticketNumber`, `dateTime`, `plays` (lista de `Bet`), `amount`, `investment`, `pay`, `balance`, `game`, `status` (`TicketStatus`).
- **`TicketStatus`** (enum): `approved`, `winner`, `loser`, `paid`, `annulled` — usado en Ventas para mostrar el ícono de estado.
- **`RaceResult`**: resultado histórico — `raceNumber`, `winner1`, `winner2`, `bonus`.
- **`RaceOdds`**: cuotas históricas — `raceNumber`, `odds` (lista de 8 valores, uno por perro).

### Datos del backend

- `_currentRace` y `_countdownSeconds` salen de `GET /race-engine/status` (sondeo cada 5s); el `Timer.periodic` de 1s solo descuenta entre sondeos.
- `resultsHistory`: `GET /races/history` — con `agencyId`, el resultado que realmente vio esa agencia.
- `oddsHistory`: `GET /odds/race/{id}` de la carrera en venta y de las últimas terminadas.
- `_currentTicketPlays`: jugadas del ticket en construcción.
- `_salesHistory`: tickets ya impresos.

Todo vive **en memoria** — al cerrar la app se pierde el estado (no hay base de datos, archivos ni `shared_preferences`).

---

## 5. Flujo de apuestas (Jugada)

El flujo completo ocurre en `PosState` y se refleja en `JugadaScreen`:

1. **Selección de perros**
   - `selectDog1(n)` / `selectDog2(n)`: alternan la selección (tap de nuevo = deseleccionar). Si el mismo número ya estaba elegido en la otra posición, se limpia automáticamente para evitar duplicar el perro en ambas posiciones.
   - `selectR()`: elige 1° y 2° lugar al azar (de un pool de 1-8, sin repetir).
   - `selectR2()`: si no hay perro en 1°, equivale a `selectR()`; si ya hay un 1° elegido, solo randomiza el 2° (excluyendo al 1°).
   - `swapSelections()`: intercambia `selectedDog1` ↔ `selectedDog2`.

2. **Monto de apuesta**
   - `addBetAmount(monto)`: suma al monto actual (botones rápidos 25/50/100/200).
   - `clearBetAmount()`: resetea el monto a 0.

3. **Auto-creación de la jugada (`addPlayToTicket`)**
   - Cada vez que cambian perro1, perro2 o el monto, `PosState` verifica: si **perro1 ≠ null Y perro2 ≠ null Y monto > 0**, se llama automáticamente a `addPlayToTicket()`.
   - `addPlayToTicket()`:
     - Busca las cuotas (`oddsHistory`) de la carrera actual (`_currentRace`).
     - Calcula la cuota combinada: `odds = clamp(odds[dog1] * odds[dog2] * 0.4, 1.5, 99.9)`, redondeada a 1 decimal.
     - Crea un `Bet` con `dog1`, `dog2`, `amount`, `odds` y lo agrega a `_currentTicketPlays`.
     - Resetea `selectedDog1`, `selectedDog2` y `currentBetAmount` a sus valores iniciales (para permitir agregar la siguiente jugada).

4. **Gestión del ticket en construcción**
   - `currentTicketPlays`: lista de `Bet` pendientes de imprimir.
   - `currentTicketTotal`: suma de los montos de todas las jugadas pendientes (mostrado en el recuadro amarillo del drawer).
   - `deletePlayAtIndex(i)`: elimina una jugada puntual del ticket.
   - `deleteCurrentTicket()`: limpia todas las jugadas y la selección/monto en curso (botón de "borrar" del bottom bar).

5. **Impresión (`printTicket`)**
   - Si no hay jugadas en `_currentTicketPlays` pero hay una selección completa pendiente (perro1+perro2+monto), primero la agrega vía `addPlayToTicket()`.
   - Si `_currentTicketPlays` no está vacío:
     - Genera fecha/hora formateada (`dd/MM/yyyy HH:mm:ss`).
     - Suma el monto total de todas las jugadas.
     - Crea un `Ticket` con `id`/`ticketNumber` correlativo (`1000 + salesHistory.length`), `status: TicketStatus.approved`, `investment = amount`, `pay = 0`, `balance = -amount`.
     - Inserta el ticket al inicio de `_salesHistory` (más reciente primero) y limpia `_currentTicketPlays`.

6. **UI del ticket (drawer deslizable en `JugadaScreen`)**
   - `_isTicketOpen` (estado local) controla un `AnimatedPositioned` que desliza el panel del ticket desde fuera de pantalla.
   - `JugadaScreen` escucha `PosState` (`_onStateChanged`) y **abre automáticamente el drawer** cuando `currentTicketPlays.length` aumenta (se agregó una jugada nueva).
   - Dentro del drawer se listan las jugadas con número, cuota, monto y los íconos de los 2 perros (`botonnumero{N}.png`), cada una con botón de borrado individual.

### Resumen de Ventas

`VentasScreen` consume getters agregados de `PosState` sobre `_salesHistory`:
- `totalMonto` = Σ `ticket.amount`
- `totalInversion` = Σ `ticket.investment`
- `totalPagar` = Σ `ticket.pay`
- `totalBalance` = Σ `ticket.balance`

---

## 6. Servicios

**No existe una capa de servicios.** No hay clases `*Service`, repositorios, ni inyección de dependencias. Toda la "lógica de negocio" (cálculo de cuotas, generación de tickets, countdown de carrera) está implementada directamente como métodos de `PosState`.

La única integración con el sistema operativo es **`window_manager`** (paquete externo), usado en `main.dart` para:
- Inicializar la ventana en plataformas desktop (Windows/Linux/macOS).
- Configurar tamaño (1920x1080, mínimo 1024x768), centrar, ocultar la barra de título nativa (`TitleBarStyle.hidden`) y maximizar al iniciar.

---

## 7. APIs

Toda la red pasa por `lib/api/api_client.dart` (paquete `http`), contra la API
de MBSport DS8. La URL base es `https://api.ds8.site` y se puede cambiar al
compilar con `--dart-define=API_BASE_URL=...`.

| Qué | Endpoint |
| --- | --- |
| Login (número de acceso + PIN) | `POST /auth/login` |
| Perfil, agencia y rol | `GET /users/me` |
| Carrera en venta, cuenta regresiva, X2/X3, límite de venta | `GET /race-engine/status` |
| Matriz de cuotas WINNER/EXACTA | `GET /odds/race/{raceId}` |
| Venta del ticket | `POST /tickets` |
| Ventas de la agencia | `GET /tickets` |
| Resultados por agencia | `GET /races/history` |

Dos reglas del backend que condicionan al cliente: **la cuota la congela el
servidor** al vender (lo que mande el POS se ignora), y **solo se vende contra
la carrera `OPEN`**, que durante la reproducción de un video es la siguiente
(venta anticipada).

La impresión del boleto es real: `lib/services/ticket_printer.dart` arma un PDF
de 80 mm y lo manda a la impresora predeterminada sin diálogo. Si la impresión
falla, la venta ya registrada NO se invalida: se avisa al cajero.
