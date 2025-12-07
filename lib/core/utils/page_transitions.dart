import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition untuk transisi yang smooth dan modern
class CustomPageTransition {
  /// Slide transition dari kanan (untuk push)
  static CustomTransitionPage slideFromRight<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition dari kanan
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var slideAnimation = animation.drive(slideTween);

        // Fade transition untuk halaman yang keluar
        var fadeTween = Tween(begin: 1.0, end: 0.0);
        var fadeAnimation = secondaryAnimation.drive(fadeTween);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation.drive(
              Tween(
                begin: 1.0,
                end: 0.8,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition (untuk transisi yang lebih halus)
  static CustomTransitionPage fade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        );
      },
    );
  }

  /// Scale transition dengan fade (modern & smooth)
  static CustomTransitionPage scaleAndFade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var scaleTween = Tween(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide dan fade transition (paling smooth untuk navigasi back)
  static CustomTransitionPage slideAndFade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 350),
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Slide animation
        var slideTween = Tween(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        // Fade animation
        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        // Secondary animation untuk halaman yang keluar
        var secondarySlide = Tween(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).chain(CurveTween(curve: curve));

        var secondaryFade = Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: curve));

        return Stack(
          children: [
            // Halaman lama (yang keluar)
            SlideTransition(
              position: secondaryAnimation.drive(secondarySlide),
              child: FadeTransition(
                opacity: secondaryAnimation.drive(secondaryFade),
                child: Container(),
              ),
            ),
            // Halaman baru (yang masuk)
            SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Material-style shared axis transition (paling modern)
  static CustomTransitionPage sharedAxis<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Fade in/out
        var fadeInTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: const Interval(0.3, 1.0, curve: curve)));

        var fadeOutTween = Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: const Interval(0.0, 0.7, curve: curve)));

        // Slide animation
        var slideInTween = Tween(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        var slideOutTween = Tween(
          begin: Offset.zero,
          end: const Offset(0.0, -0.05),
        ).chain(CurveTween(curve: curve));

        return Stack(
          children: [
            // Exiting page
            SlideTransition(
              position: secondaryAnimation.drive(slideOutTween),
              child: FadeTransition(
                opacity: secondaryAnimation.drive(fadeOutTween),
                child: Container(),
              ),
            ),
            // Entering page
            SlideTransition(
              position: animation.drive(slideInTween),
              child: FadeTransition(
                opacity: animation.drive(fadeInTween),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  /// No transition (instant navigation)
  static CustomTransitionPage noTransition<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
