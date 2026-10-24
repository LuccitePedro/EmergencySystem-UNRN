/// Une los elementos con coma mostrando como máximo [maximo]; el resto se resume como "y N más".
/// Así la tarjeta principal y la notificación no crecen sin límite si hay muchos datos cargados.
String resumirLista(Iterable<String> items, String vacio, {int maximo = 3}) {
  final lista = items.toList();
  if (lista.isEmpty) return vacio;
  if (lista.length <= maximo) return lista.join(', ');
  return '${lista.take(maximo).join(', ')} y ${lista.length - maximo} más';
}
