class Cooperative {
  final int id;
  final String? nameCooperative;
  final String? municipalityId;
  final String? nif;
  final String? numCnaps;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? dateDescente;
  final String? slogantCooperative;


  /// Nouveau champ pour paiement
  final int? droitAdhesion;

  Cooperative({
    required this.id,
    this.nameCooperative,
    this.municipalityId,
    this.nif,
    this.numCnaps,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.dateDescente,
    this.droitAdhesion,
    this.slogantCooperative,

  });

  factory Cooperative.fromJson(Map<String, dynamic> json) {
    return Cooperative(
      id: json['id'] as int,
      nameCooperative: json['name_cooperative'] as String?,
      municipalityId: json['municipality_id'] as String?,
      nif: json['nif'] as String?,
      numCnaps: json['num_cnaps'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      dateDescente: json['date_descente'] as String?,
      droitAdhesion: json['droit_adhesion'] as int?, // <— mapping
      slogantCooperative: json['slogant_cooperative'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_cooperative': nameCooperative,
      'municipality_id': municipalityId,
      'nif': nif,
      'num_cnaps': numCnaps,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'date_descente': dateDescente,
      'droit_adhesion': droitAdhesion,
      'slogant_cooperative': slogantCooperative,

    };
  }
}
