import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/documents_repository.dart';

// Regroupe les informations nécessaires pour identifier un document précis.
class DocumentParams {
  final String id;
  final String url;
  final String nom;
  const DocumentParams({required this.id, required this.url, required this.nom});

  @override
  bool operator ==(Object other) =>
      other is DocumentParams && other.id == id && other.url == url && other.nom == nom;

  @override
  int get hashCode => Object.hash(id, url, nom);
}

sealed class EtatDocument {
  const EtatDocument();
}

class DocumentNonTelecharge extends EtatDocument {
  const DocumentNonTelecharge();
}

class DocumentEnTelechargement extends EtatDocument {
  final double progression;
  const DocumentEnTelechargement(this.progression);
}

class DocumentTelecharge extends EtatDocument {
  final String cheminLocal;
  const DocumentTelecharge(this.cheminLocal);
}

class DocumentErreurTelechargement extends EtatDocument {
  final String message;
  const DocumentErreurTelechargement(this.message);
}

class DocumentController extends StateNotifier<EtatDocument> {
  final DocumentsRepository _repository;
  final String documentId;
  final String urlFichier;
  final String nomFichier;

  DocumentController(
    this._repository, {
    required this.documentId,
    required this.urlFichier,
    required this.nomFichier,
  }) : super(const DocumentNonTelecharge()) {
    _verifierSiDejaTelecharge();
  }

  Future<void> _verifierSiDejaTelecharge() async {
    final chemin = await _repository.cheminLocal(documentId, nomFichier);
    final existe = await _repository.estDejaTelecharge(chemin);
    if (existe) {
      state = DocumentTelecharge(chemin);
    }
  }

  Future<void> telecharger() async {
    state = const DocumentEnTelechargement(0);
    try {
      final chemin = await _repository.cheminLocal(documentId, nomFichier);
      await _repository.telecharger(
        urlFichier: urlFichier,
        cheminDestination: chemin,
        onProgression: (p) => state = DocumentEnTelechargement(p),
      );
      state = DocumentTelecharge(chemin);
    } catch (e) {
      state = const DocumentErreurTelechargement(
        'Téléchargement impossible. Vérifiez votre connexion et réessayez.',
      );
    }
  }
}

final documentControllerProvider =
    StateNotifierProvider.family<DocumentController, EtatDocument, DocumentParams>(
  (ref, params) {
    return DocumentController(
      ref.watch(documentsRepositoryProvider),
      documentId: params.id,
      urlFichier: params.url,
      nomFichier: params.nom,
    );
  },
);
