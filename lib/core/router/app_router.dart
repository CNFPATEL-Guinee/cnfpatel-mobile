import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentification/presentation/screens/connexion_screen.dart';
import '../../features/authentification/providers/auth_controller.dart';
import '../../features/accueil/presentation/screens/accueil_screen.dart';
import '../../features/accueil/presentation/screens/bienvenue_screen.dart';
import '../../features/formations/presentation/screens/formations_list_screen.dart';
import '../widgets/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final onConnexion = state.matchedLocation == '/connexion';
      final onBienvenue = state.matchedLocation == '/bienvenue';

      if (authState is AuthVerificationEnCours) {
        return null;
      }

      final estConnecte = authState is AuthConnecte;

      // Non connecte : direction la page d accueil publique (sauf si
      // deja sur cette page ou sur la connexion).
      if (!estConnecte && !onConnexion && !onBienvenue) return '/bienvenue';
      // Connecte : on ne reste pas sur les pages publiques/connexion.
      if (estConnecte && (onConnexion || onBienvenue)) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'accueil',
        builder: (context, state) {
          if (authState is AuthVerificationEnCours) {
            return const SplashScreen();
          }
          return const AccueilScreen();
        },
      ),
      GoRoute(
        path: '/bienvenue',
        name: 'bienvenue',
        builder: (context, state) => const BienvenueScreen(),
      ),
      GoRoute(
        path: '/connexion',
        name: 'connexion',
        builder: (context, state) => const ConnexionScreen(),
      ),
      GoRoute(
        path: '/formations',
        name: 'formations',
        builder: (context, state) => const FormationsListScreen(),
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}
