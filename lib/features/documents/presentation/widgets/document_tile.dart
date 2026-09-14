import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/document_model.dart';

class DocumentTile extends StatelessWidget {
  final DocumentCours document;
  const DocumentTile({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
      title: Text(document.titre),
      subtitle: document.tailleLisible.isNotEmpty
          ? Text(document.tailleLisible, style: const TextStyle(fontSize: 12))
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new_rounded),
        tooltip: 'Ouvrir',
        onPressed: () => _ouvrirDocument(context),
      ),
      onTap: () => _ouvrirDocument(context),
    );
  }

  Future<void> _ouvrirDocument(BuildContext context) async {
    final uri = Uri.parse(document.urlFichier);
    final ouvert = await launchUrl(uri, webOnlyWindowName: '_self');

    if (!ouvert && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir ce document."),
        ),
      );
    }
  }
}
