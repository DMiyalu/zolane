enum EntrySource {
  immo,
  salaire,
  autres,
}

enum ExpenseType {
  chargesImmo,
  personnelle,
}

enum ImmoProperty {
  bergere,
  commentry,
  chayet,
}

enum ImmoChargeReason {
  assurance,
  electricite,
  eau,
  autres,
}

enum PersonalReason {
  menage,
  transport,
  sante,
  autres,
}

extension ImmoPropertyExtension on ImmoProperty {
  String get label {
    switch (this) {
      case ImmoProperty.bergere:
        return 'Bergère';
      case ImmoProperty.commentry:
        return 'Commentry';
      case ImmoProperty.chayet:
        return 'Chayet';
    }
  }
}

extension EntrySourceExtension on EntrySource {
  String get label {
    switch (this) {
      case EntrySource.immo:
        return 'Immo';
      case EntrySource.salaire:
        return 'Salaire';
      case EntrySource.autres:
        return 'Autres';
    }
  }
}

extension ExpenseTypeExtension on ExpenseType {
  String get label {
    switch (this) {
      case ExpenseType.chargesImmo:
        return 'Charges immobilières';
      case ExpenseType.personnelle:
        return 'Personnelle';
    }
  }
}

extension ImmoChargeReasonExtension on ImmoChargeReason {
  String get label {
    switch (this) {
      case ImmoChargeReason.assurance:
        return 'Assurance';
      case ImmoChargeReason.electricite:
        return 'Électricité';
      case ImmoChargeReason.eau:
        return 'Eau';
      case ImmoChargeReason.autres:
        return 'Autres';
    }
  }
}

extension PersonalReasonExtension on PersonalReason {
  String get label {
    switch (this) {
      case PersonalReason.menage:
        return 'Ménage';
      case PersonalReason.transport:
        return 'Transport';
      case PersonalReason.sante:
        return 'Santé';
      case PersonalReason.autres:
        return 'Autres';
    }
  }
}

