import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import '../../auth/presentation/pages/login_screen.dart'; // Navigate to Login by default
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController c1;
  late AnimationController c2;
  late AnimationController c3;

  late Animation<double> fade1;
  late Animation<double> fade2;
  late Animation<double> fade3;

  late Animation<Offset> slide1;
  late Animation<Offset> slide2;
  late Animation<Offset> slide3;

  @override
  void initState() {
    super.initState();

    c1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    c2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    c3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    fade1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: c1, curve: Curves.easeOut));
    fade2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: c2, curve: Curves.easeOut));
    fade3 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: c3, curve: Curves.easeOut));

    slide1 = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: c1, curve: Curves.easeOut));
    slide2 = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: c2, curve: Curves.easeOut));
    slide3 = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: c3, curve: Curves.easeOut));

    // Staggered animation
    Future.delayed(const Duration(milliseconds: 500), () => c1.forward());
    Future.delayed(const Duration(milliseconds: 1500), () => c2.forward());
    Future.delayed(const Duration(milliseconds: 2500), () => c3.forward());

    // Navigation handled by wrapper in main.dart, but standard practice is here too.
    // However, main.dart has logic. I will let main.dart handle it or handle it here.
    // The wrapper in main.dart handles it.
  }

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    super.dispose();
  }

  Widget animatedItem(Animation<double> fade, Animation<Offset> slide, Widget child) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            animatedItem(
              fade1,
              slide1,
              Text(
                AppLocalizations.of(context)!.facultyName,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            animatedItem(
              fade2,
              slide2,
              Text(
                AppLocalizations.of(context)!.universityName,
                style: GoogleFonts.notoNastaliqUrdu(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            animatedItem(
              fade3,
              slide3,
              Image.asset(
                "assets/ChatGPT Image Nov 22, 2025, 07_36_03 PM.png",
                width: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}











// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../l10n/app_localizations.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
//   late AnimationController controller;
//   late Animation<double> scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Controller واحد لكل العناصر
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     // Scale من صغير لكبير (Zoom)
//     scaleAnimation = Tween<double>(begin: 0.1, end: 1).animate(
//       CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
//     );
//
//     // شغل الأنيميشن
//     controller.forward();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   Widget zoomItem(Widget child) {
//     return ScaleTransition(
//       scale: scaleAnimation,
//       child: child,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             zoomItem(
//               Text(
//                 AppLocalizations.of(context)!.facultyName,
//                 style: GoogleFonts.notoNastaliqUrdu(
//                   fontSize: 27,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             zoomItem(
//               Text(
//                 AppLocalizations.of(context)!.universityName,
//                 style: GoogleFonts.notoNastaliqUrdu(
//                   fontSize: 27,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             zoomItem(
//               Image.asset(
//                 "assets/ChatGPT Image Nov 22, 2025, 07_36_03 PM.png",
//                 width: 300,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





