import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';

class TopicCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color? backgroundColor;
  final Color? iconForeground;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;

  const TopicCard({
    Key? key,
    required this.icon,
    required this.iconBackground,
    this.backgroundColor,
    this.iconForeground,
    required this.title,
    required this.subtitle,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon rounded square
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconBackground.withOpacity(0.5),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconForeground ?? Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        textStyle: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Full-width CTA
          SizedBox(
            width: double.infinity,
            child: AnimatedScaleButton(
              onPressed: onPressed,
              pressedScale: .95,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF13AF25), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF13AF25), offset: Offset(0, 6)),
                  ],
                ),
                child: Text(
                  AppLocalizations.of(context).topic_start_button,
                  style: GoogleFonts.notoSans(
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
