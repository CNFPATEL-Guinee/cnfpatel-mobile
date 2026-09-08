import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/api/api_client.dart';

// Gère le téléchargement des documents vers le stockage local du téléphone,
// pour qu'ils restent consultables hors-ligne une fois téléchargés une fois.
class DocumentsRepository {
  final Dio _dio;
  DocumentsRepository(this._dio);

  // Renvoie le chemin local où le fichier est (ou sera) enregistré.
  Future<String> cheminLocal(String documentId, String nomFichier) async {
    final dossier = await getApplicationDocumentsDirectory();
    return '${dossier.path}/$documentId-$nomFichier';
  }

  // Vérifie si le document a déjà été téléchargé précédemment.
  Future<bool> estDejaTelecharge(String cheminLocal) async {
    return File(cheminLocal).exists();
  }

  // Télécharge le fichier, avec suivi de la progression (utile sur une
  // connexion lente ou instable, pour rassurer l'apprenant que ça avance).
  Future<void> telecharger({
    required String urlFichier,
    required String cheminDestination,
    required void Function(double progression) onProgression,
  }) async {
    await _dio.download(
      urlFichier,
      cheminDestination,
      onReceiveProgress: (recu, total) {
        if (total > 0) {
          onProgression(recu / total);
        }
      },
    );
  }
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DocumentsRepository(dio);
});
