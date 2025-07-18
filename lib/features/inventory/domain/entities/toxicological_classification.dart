enum ToxicologicalClassification {
  ia, // Extremadamente peligroso
  ib, // Altamente peligroso
  ii, // Moderadamente peligroso
  iii, // Ligeramente peligroso
  iv, // Productos que normalmente no ofrecen peligro
  u, // Es improbable que presente peligro agudo
}

extension ToxicologicalClassificationExtension on ToxicologicalClassification {
  String get displayName {
    switch (this) {
      case ToxicologicalClassification.ia:
        return 'Clase Ia - Extremadamente peligroso';
      case ToxicologicalClassification.ib:
        return 'Clase Ib - Altamente peligroso';
      case ToxicologicalClassification.ii:
        return 'Clase II - Moderadamente peligroso';
      case ToxicologicalClassification.iii:
        return 'Clase III - Ligeramente peligroso';
      case ToxicologicalClassification.iv:
        return 'Clase IV - Normalmente no ofrece peligro';
      case ToxicologicalClassification.u:
        return 'Clase U - Improbable que presente peligro agudo';
    }
  }

  String get colorCode {
    switch (this) {
      case ToxicologicalClassification.ia:
      case ToxicologicalClassification.ib:
        return 'red'; // Rojo
      case ToxicologicalClassification.ii:
        return 'yellow'; // Amarillo
      case ToxicologicalClassification.iii:
        return 'blue'; // Azul
      case ToxicologicalClassification.iv:
        return 'green'; // Verde
      case ToxicologicalClassification.u:
        return 'white'; // Blanco
    }
  }
}