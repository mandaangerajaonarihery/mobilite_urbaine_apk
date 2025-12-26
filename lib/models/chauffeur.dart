    class Chauffeur {
      final int? id;
      final String? numPhonChauffeur;
      final String? numPermisChauffeur;
      final String? categoriPermis;
      final String? municipalityId;
      final String? cityzenId;

      // Données citoyen
      final String? nom; // alias
      final String? prenom; // alias
      final String? cin; // alias pour carteIdentiteNationnal
      final String? photo; // alias pour photoChauffeur
      final String? adresse;

      // Image permis chauffeur
      final String? permisImage;

      Chauffeur({
        this.id,
        this.numPhonChauffeur,
        this.numPermisChauffeur,
        this.categoriPermis,
        this.municipalityId,
        this.cityzenId,
        this.nom,
        this.prenom,
        this.cin,
        this.photo,
        this.adresse,
        this.permisImage,
      });
    // Dans votre fichier models/chauffeur.dart

    factory Chauffeur.fromJson(Map<String, dynamic> json) {
      final citizen = json['citizen'] ?? {};

      // --- Début de la logique pour enlever la base de l'URL ---
      final String? fullPhotoUrl = citizen['photo_chauffeur'];
      String? photoFilename; // Variable pour stocker le résultat

      if (fullPhotoUrl != null) {
        const String baseUrlToRemove = 'https://gateway.tsirylab.com/serviceupload/file/';
        
        if (fullPhotoUrl.startsWith(baseUrlToRemove)) {
          // Si l'URL commence par la base, on la supprime
          photoFilename = fullPhotoUrl.replaceFirst(baseUrlToRemove, '');
        } else {
          // Sinon, on garde l'URL telle quelle (sécurité)
          photoFilename = fullPhotoUrl;
        }
      }
      // --- Fin de la logique ---

//       return Chauffeur(
//         id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
//         numPhonChauffeur: json['numPhon_chauffeur']?.toString(),
//         numPermisChauffeur: json['numPermis_chauffeur']?.toString(),
//         categoriPermis: json['categori_permis']?.toString(),
//       municipalityId: json['municipality_id']?.toString(),

//         cityzenId: json['cityzen_id']?.toString(),

//         // alias
//         nom: citizen['citizen_name'] ?? json['nom_chauffeur'],
// prenom: citizen['citizen_lastname'] ?? json['prenom_chauffeur'],
// cin: citizen['citizen_national_card_number']?.toString() ?? json['carte_identite_nationnal']?.toString(),
        
//         // On utilise notre variable qui contient maintenant que le nom du fichier
//         photo: photoFilename, 
        
//         adresse: citizen['adresse'] ?? json['adresse'],
//         permisImage: json['permis_image'],
//       );
return Chauffeur(
    id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
    numPhonChauffeur: json['numPhon_chauffeur']?.toString(),
    numPermisChauffeur: json['numPermis_chauffeur']?.toString(),
    categoriPermis: json['categori_permis']?.toString(),
    municipalityId: json['municipality_id']?.toString(),
    cityzenId: json['cityzen_id']?.toString(),

    nom: citizen['citizen_name'],
    prenom: citizen['citizen_lastname'],
    cin: citizen['citizen_national_card_number']?.toString(),
    photo: citizen['citizen_photo'], // URL complète
    adresse: citizen['citizen_adress'],
    permisImage: json['permis_image'], // chemin relatif
  );
    }
      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'numPhon_chauffeur': numPhonChauffeur,
          'numPermis_chauffeur': numPermisChauffeur,
          'categori_permis': categoriPermis,
          'municipality_id': municipalityId,
          'cityzen_id': cityzenId,
          'permis_image': permisImage,
          'citizen': {
            'nom_chauffeur': nom,
            'prenom_chauffeur': prenom,
            'carte_identite_nationnal': cin,
            'photo_chauffeur': photo,
            'adresse': adresse,
          }
        };
      }
    }
