import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos/state/pos_state.dart';

/// Impresión del boleto en papel térmico de 80 mm.
///
/// El ancho es fijo (80 mm) y el alto crece con la cantidad de jugadas, para
/// que la impresora corte justo debajo de la última línea en vez de expulsar
/// una hoja entera.
class TicketPrinter {
  /// Manda el ticket a la impresora predeterminada sin abrir diálogo (que es
  /// lo que necesita una caja: vender e imprimir de un solo toque). Si no hay
  /// impresora predeterminada, cae al diálogo del sistema.
  ///
  /// Devuelve `null` si imprimió, o el motivo del fallo para avisar al cajero.
  static Future<String?> print({
    required Ticket ticket,
    required int raceNumber,
    required String agencyName,
    required String cashier,
  }) async {
    try {
      final bytes = await build(
        ticket: ticket,
        raceNumber: raceNumber,
        agencyName: agencyName,
        cashier: cashier,
      );

      // Impresora predeterminada del sistema, sin abrir ningún diálogo.
      final printers = await Printing.listPrinters();
      final defaultPrinter = printers.where((p) => p.isDefault).firstOrNull ??
          printers.firstOrNull;

      if (defaultPrinter != null) {
        await Printing.directPrintPdf(
          printer: defaultPrinter,
          onLayout: (_) async => bytes,
          name: 'Ticket ${ticket.ticketNumber}',
        );
        return null;
      }

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Ticket ${ticket.ticketNumber}',
      );
      return null;
    } catch (e) {
      return 'No se pudo imprimir: $e';
    }
  }

  /// Genera el PDF del boleto. Separado de `print` para poder probarlo.
  static Future<Uint8List> build({
    required Ticket ticket,
    required int raceNumber,
    required String agencyName,
    required String cashier,
  }) async {
    final doc = pw.Document();

    // 80 mm de ancho; el alto se estima por la cantidad de jugadas.
    const width = 80 * PdfPageFormat.mm;
    final height = (110 + ticket.plays.length * 12) * PdfPageFormat.mm / 10;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(width, height, marginAll: 4 * PdfPageFormat.mm),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                'MBSPORT DS8',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(child: pw.Text('RACING DOG', style: const pw.TextStyle(fontSize: 9))),
            pw.SizedBox(height: 6),
            _line(),
            _row('Ticket', '#${ticket.ticketNumber}', bold: true),
            _row('Carrera', '$raceNumber'),
            _row('Fecha', ticket.dateTime),
            if (agencyName.isNotEmpty) _row('Agencia', agencyName),
            _row('Cajero', cashier),
            _line(),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Expanded(flex: 3, child: pw.Text('JUGADA', style: _small(bold: true))),
                pw.Expanded(flex: 2, child: pw.Text('CUOTA', style: _small(bold: true))),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('MONTO',
                      textAlign: pw.TextAlign.right, style: _small(bold: true)),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            ...ticket.plays.map(
              (play) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        play.dog2 == null
                            ? 'GANA ${play.dog1}'
                            : 'EXACTA ${play.dog1}-${play.dog2}',
                        style: _small(),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(play.odds.toStringAsFixed(2), style: _small()),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        play.amount.toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: _small(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            _line(),
            _row('TOTAL', 'RD\$ ${ticket.amount.toStringAsFixed(2)}', bold: true),
            _line(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: '${ticket.ticketNumber}',
                width: 140,
                height: 40,
                drawText: false,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text('${ticket.ticketNumber}', style: _small())),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'Conserve este boleto para reclamar su premio',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7),
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static pw.TextStyle _small({bool bold = false}) => pw.TextStyle(
        fontSize: 8,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );

  static pw.Widget _line() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Divider(height: 1, thickness: 0.5),
      );

  static pw.Widget _row(String label, String value, {bool bold = false}) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: _small(bold: bold)),
          pw.Text(value, style: _small(bold: bold)),
        ],
      );
}
