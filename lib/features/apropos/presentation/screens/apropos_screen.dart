import 'package:flutter/material.dart';

class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  static const String versionApp = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A propos')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE6F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 48,
                    color: Color(0xFF1F3864),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CNFPATEL Guinee',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Centre National de Formation et de Perfectionnement\n'
                  'des Administrateurs Territoriaux et Elus Locaux',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),

          _sectionTitre(context, 'Notre mission'),
          const SizedBox(height: 8),
          Text(
            "Le CNFPATEL, sous la tutelle du Ministere de l'Administration "
            "du Territoire et de la Decentralisation (MATD), a pour mission "
            "de former et de perfectionner les cadres et elus locaux de la "
            "Republique de Guinee en gestion administrative, deconcentration "
            "et decentralisation, deontologie de la fonction d'autorite "
            "administrative, et leadership et management.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),

          const SizedBox(height: 28),
          _sectionTitre(context, 'Contact'),
          const SizedBox(height: 8),
          _ligneContact(Icons.phone_outlined, 'Telephone', 'A completer'),
          _ligneContact(Icons.email_outlined, 'Email', 'A completer'),
          _ligneContact(Icons.location_on_outlined, 'Adresse', 'A completer'),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version $versionApp',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitre(BuildContext context, String texte) {
    return Text(
      texte,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F3864),
          ),
    );
  }

  Widget _ligneContact(IconData icone, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(valeur, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
