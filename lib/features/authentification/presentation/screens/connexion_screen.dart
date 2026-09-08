import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';

class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).connecter(
          telephone: _telephoneController.text.trim(),
          motDePasse: _motDePasseController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final enCours = authState is AuthConnexionEnCours;
    final messageErreur =
        authState is AuthNonConnecte ? authState.messageErreur : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.school_rounded, size: 56, color: Color(0xFF1F3864)),
                  const SizedBox(height: 12),
                  Text(
                    'CNFPATEL Guinée',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF1F3864),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formation des cadres et élus locaux',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 36),
                  if (messageErreur != null) ...[
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
                              messageErreur,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Numéro de téléphone', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Ex : 622000000',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.trim().length < 8) {
                        return 'Entrez un numéro de téléphone valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('Mot de passe', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_motDePasseVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _motDePasseVisible = !_motDePasseVisible),
                      ),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.isEmpty) {
                        return 'Entrez votre mot de passe';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _soumettre(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: enCours ? null : _soumettre,
                    child: enCours
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Se connecter', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
