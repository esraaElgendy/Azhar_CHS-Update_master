import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../l10n/app_localizations.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.transparent,
          child: Image.asset("assets/ChatGPT Image Nov 22, 2025, 07_36_03 PM.png"),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.facultyName,
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.studentPortal,
          style: GoogleFonts.notoNastaliqUrdu(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
          ),
        ),
      ],
    );
  }
}
