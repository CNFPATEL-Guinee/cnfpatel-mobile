import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';

const _rangs = ['Prefet', 'Sous-prefet', 'Secretaire-general', 'Maire', 'Chef-cabinet'];

class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _motDePasseVisible = false;
  String _role = 'apprenant';
  String? _rang;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(inscriptionControllerProvider.notifier).inscrire(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: _telephoneController.text.trim(),
          motDePasse: _motDePasseController.text,
          role: _role,
          rang: _role == 'apprenant' ? _rang : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final inscriptionState = ref.watch(inscriptionControllerProvider);
    final enCours = inscriptionState is InscriptionEnCours;

    ref.listen<InscriptionState>(inscriptionControllerProvider, (previous, next) {
      if (next is InscriptionReussie) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Compte créé'),
            content: Text(next.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ferme le dialogue
                  Navigator.of(context).pop(); // retourne à l écran de connexion
                },
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (inscriptionState is InscriptionEchouee) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inscriptionState.message,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade400, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Votre compte devra être approuvé par un administrateur avant que vous puissiez vous connecter.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Prénom', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _prenomController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                Text('Nom', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nomController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                Text('Numéro de téléphone', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Ex : 622000000'),
                  validator: (v) => (v == null || v.trim().length < 8) ? 'Numéro invalide' : null,
                ),
                const SizedBox(height: 16),

                Text('Mot de passe', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _motDePasseController,
                  obscureText: !_motDePasseVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_motDePasseVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 4) ? 'Au moins 4 caractères' : null,
                ),
                const SizedBox(height: 16),

                Text('Je suis', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'apprenant', label: Text('Apprenant')),
                    ButtonSegment(value: 'formateur', label: Text('Formateur')),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() {
                    _role = s.first;
                    if (_role != 'apprenant') _rang = null;
                  }),
                ),

                if (_role == 'apprenant') ...[
                  const SizedBox(height: 16),
                  Text('Rang / Fonction', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _rang,
                    hint: const Text('Sélectionnez votre rang'),
                    items: _rangs
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _rang = v),
                    validator: (v) => v == null ? 'Sélectionnez votre rang' : null,
                  ),
                ],

                const SizedBox(height: 28),
                FilledButton(
                  onPressed: enCours ? null : _soumettre,
                  child: enCours
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon compte', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
