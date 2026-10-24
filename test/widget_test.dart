import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emergency_system/main.dart';
import 'package:emergency_system/models/perfil_medico.dart';
import 'package:emergency_system/screens/pantalla_categoria_carousel.dart';
import 'package:emergency_system/screens/pantalla_editar_perfil.dart';
import 'package:emergency_system/utils/texto.dart';

const _perfil = PerfilMedico(
  nombre: 'Juan Pérez',
  grupoSanguineo: 'O+',
  alergias: [
    Alergia(nombre: 'Penicilina', reaccion: 'Urticaria', severidad: 'Grave', queHacer: 'Llamar al 911'),
  ],
  enfermedades: [],
  medicacion: [],
  vacunas: [],
  obraSocial: 'OSDE',
  numeroSocio: '123',
  restriccionesAlimentarias: ['Celíaco'],
  contactos: [
    ContactoEmergencia(nombre: 'Ana Pérez', relacion: 'Madre', telefono: '2995550001'),
    ContactoEmergencia(nombre: 'Luis Gómez', relacion: 'Amigo', telefono: '2995550002'),
    ContactoEmergencia(nombre: 'Sofía Díaz', relacion: 'Tía', telefono: '2995550003'),
  ],
);

void main() {
  test('El perfil se conserva al pasarlo a JSON y volver', () {
    final copia = PerfilMedico.fromJson(_perfil.toJson());

    expect(copia.nombre, 'Juan Pérez');
    expect(copia.grupoSanguineo, 'O+');
    expect(copia.alergias.single.severidad, 'Grave');
    expect(copia.restriccionesAlimentarias, ['Celíaco']);
    expect(copia.contactos.map((c) => c.telefono),
        ['2995550001', '2995550002', '2995550003']);
  });

  test('El perfil vacío se detecta como vacío', () {
    expect(PerfilMedico.vacio.estaVacio, isTrue);
    expect(_perfil.estaVacio, isFalse);
  });

  testWidgets('La pantalla principal muestra los datos, el lápiz de edición y hasta 2 contactos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaPerfilMedico(perfil: _perfil)));

    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.textContaining('O+ (positivo)', findRichText: true), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.textContaining('Penicilina (Grave)', findRichText: true), findsOneWidget);
    expect(find.text('Restricciones'), findsOneWidget);

    expect(find.text('911'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Luis'), findsOneWidget);
    expect(find.text('Sofía'), findsNothing);
  });

  testWidgets('Sin contactos se muestra un único botón de emergencia', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PantallaPerfilMedico(perfil: _perfil.copyWith(contactos: [])),
    ));

    expect(find.text('Emergencia'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  test('Las listas largas se resumen', () {
    expect(resumirLista([], 'No'), 'No');
    expect(resumirLista(['A', 'B', 'C'], 'No'), 'A, B, C');
    expect(resumirLista(['A', 'B', 'C', 'D', 'E'], 'No'), 'A, B, C y 2 más');
  });

  testWidgets('El campo de fecha solo acepta fechas válidas', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PantallaEditarPerfil(perfilActual: PerfilMedico.vacio),
    ));
    await tester.scrollUntilVisible(find.text('Agregar vacuna'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Agregar vacuna'));
    await tester.pumpAndSettle();

    final campoFecha = find.widgetWithText(TextFormField, 'Fecha de aplicación');
    final campoNombre = find.widgetWithText(TextField, 'Nombre (ej: COVID-19)');
    await tester.enterText(campoNombre, 'COVID-19');

    // Las letras se descartan y las barras se agregan solas
    await tester.enterText(campoFecha, 'ab20012021');
    expect(find.text('20/01/2021'), findsOneWidget);

    Future<void> probar(String digitos, String? error) async {
      await tester.enterText(campoFecha, digitos);
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();
      if (error != null) expect(find.text(error), findsOneWidget);
    }

    await probar('2001', 'Completá la fecha: dd/mm/aaaa');
    await probar('31022021', 'Fecha inválida');
    await probar('01019999', 'La fecha no puede ser futura');

    // Con una fecha válida se agrega y se cierra el diálogo
    await probar('20012021', null);
    expect(find.text('Fecha de aplicación'), findsNothing);
    expect(find.text('COVID-19'), findsOneWidget);
  });

  group('Con 40 alergias cargadas', () {
    final muchas = _perfil.copyWith(alergias: [
      for (var i = 1; i <= 40; i++)
        Alergia(nombre: 'Alergia $i', reaccion: 'Reacción $i', severidad: 'Leve', queHacer: ''),
    ]);

    testWidgets('la tarjeta principal no crece: muestra 3 y resume el resto',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PantallaPerfilMedico(perfil: muchas)));

      expect(
          find.textContaining('Alergia 1 (Leve), Alergia 2 (Leve), Alergia 3 (Leve) y 37 más',
              findRichText: true),
          findsOneWidget);
    });

    testWidgets('la sección tiene barra de desplazamiento y llega hasta la última',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PantallaCategoriaCarousel(perfil: muchas, indiceInicial: 1),
      ));

      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.text('Alergia 40'), findsNothing);

      await tester.scrollUntilVisible(find.text('Alergia 40'), 500,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('Alergia 40'), findsOneWidget);
    });
  });
}
