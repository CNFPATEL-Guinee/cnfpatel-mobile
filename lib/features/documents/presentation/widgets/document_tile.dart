import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../data/models/document_model.dart';
import '../../providers/document_controller.dart';

class DocumentTile extends ConsumerWidget {
  final DocumentCours document;
  const DocumentTile({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = DocumentParams(
      id: document.id,
      url: document.urlFichier,
      nom: document.titre,
    );
    final etat = ref.watch(documentControllerProvider(params));

    return ListTile(
      leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
      title: Text(document.titre),
      subtitle: document.tailleLisible.isNotEmpty
          ? Text(document.tailleLisible, style: const TextStyle(fontSize: 12))
          : null,
      trailing: _boutonAction(context, ref, params, etat),
    );
  }

  Widget _boutonAction(
    BuildContext context,
    WidgetRef ref,
    DocumentParams params,
    EtatDocument etat,
  ) {
    return switch (etat) {
      DocumentNonTelecharge() => IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Télécharger',
          onPressed: () =>
              ref.read(documentControllerProvider(params).notifier).telecharger(),
        ),
      DocumentEnTelechargement(:final progression) => SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(value: progression, strokeWidth: 3),
        ),
      DocumentTelecharge(:final cheminLocal) => IconButton(
          icon: const Icon(Icons.open_in_new_rounded, color: Colors.green),
          tooltip: 'Ouvrir',
          onPressed: () async {
            final resultat = await OpenFilex.open(cheminLocal);
            if (resultat.type != ResultType.done && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Aucune application capable d\'ouvrir ce fichier PDF n\'est installée sur cet appareil.',
                  ),
                ),
              );
            }
          },
        ),
      DocumentErreurTelechargement() => IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.red),
          tooltip: 'Réessayer',
          onPressed: () =>
              ref.read(documentControllerProvider(params).notifier).telecharger(),
        ),
    };
  }
}
