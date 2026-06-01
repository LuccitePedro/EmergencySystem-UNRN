/// Modelo central de datos del perfil médico.
/// Por ahora tiene datos hardcodeados; cuando agreguemos
/// shared_preferences, solo cambiamos este archivo.
class PerfilMedico {
  final String nombre;
  final String grupoSanguineo;
  final List<String> alergias;
  final List<String> enfermedades;
  final List<String> medicacion;
  final List<String> vacunas;
  final String obraSocial;
  final String numeroSocio;
  final List<String> restriccionesAlimentarias;
  final List<ContactoEmergencia> contactos;

  const PerfilMedico({
    required this.nombre,
    required this.grupoSanguineo,
    required this.alergias,
    required this.enfermedades,
    required this.medicacion,
    required this.vacunas,
    required this.obraSocial,
    required this.numeroSocio,
    required this.restriccionesAlimentarias,
    required this.contactos,
  });

  /// Datos de ejemplo. Reemplazar con carga desde storage.
  static const PerfilMedico ejemplo = PerfilMedico(
    nombre: 'Persona Equis',
    grupoSanguineo: 'A+',
    alergias: ['Penicilina', 'Ibuprofeno'],
    enfermedades: ['Diabetes tipo 2', 'Hipertensión'],
    medicacion: ['Metformina 500mg (mañana)', 'Enalapril 10mg (noche)'],
    vacunas: ['COVID-19 (2022)', 'Gripe (2024)', 'Tétanos (2021)'],
    obraSocial: 'OSDE 310',
    numeroSocio: '1234567-8',
    restriccionesAlimentarias: ['Sin gluten', 'Sin lactosa'],
    contactos: [
      ContactoEmergencia(nombre: 'María García', relacion: 'Madre', telefono: '2944123456'),
      ContactoEmergencia(nombre: 'Carlos Equis', relacion: 'Padre', telefono: '2944654321'),
    ],
  );
}

class ContactoEmergencia {
  final String nombre;
  final String relacion;
  final String telefono;

  const ContactoEmergencia({
    required this.nombre,
    required this.relacion,
    required this.telefono,
  });
}