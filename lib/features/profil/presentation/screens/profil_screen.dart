import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentification/providers/auth_controller.dart';
import '../../data/repositories/profil_repository.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancienController = TextEditingController();
  final _nouveauController = TextEditingController();
  bool _enCours = false;
  String? _message;
  bool _messageEstErreur = false;

  @override
  void dispose() {
    _ancienController.dispose();
    _nouveauController.dispose();
    super.dispose();
  }

  Future<void> _modifierMotDePasse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _message = null;
    });

    final authState = ref.read(authControllerProvider);
    final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';

    try {
      await ref.read(profilRepositoryProvider).modifierMotDePasse(
            utilisateurId: utilisateurId,
            ancienMotDePasse: _ancienController.text,
            nouveauMotDePasse: _nouveauController.text,
          );
      setState(() {
        _message = 'Mot de passe modifié avec succès.';
        _messageEstErreur = false;
        _ancienController.clear();
        _nouveauController.clear();
      });
    } on ErreurModificationMotDePasse catch (e) {
      setState(() {
        _message = e.message;
        _messageEstErreur = true;
      });
    } finally {
      setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final utilisateur = authState is AuthConnecte ? authState.utilisateur : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFDCE6F1),
                  child: Text(
                    utilisateur != null && utilisateur.prenom.isNotEmpty
                        ? utilisateur.prenom[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F3864)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  utilisateur?.nomComplet ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  utilisateur?.telephone ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),
          Text('Changer le mot de passe', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _messageEstErreur ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _messageEstErreur ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _ancienController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nouveauController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                  validator: (v) => (v == null || v.length < 4) ? 'Au moins 4 caractères' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _enCours ? null : _modifierMotDePasse,
                    child: _enCours
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Modifier le mot de passe'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
