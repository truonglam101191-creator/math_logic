import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/widgets/gradient_button_widget.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

class DiscriptionPopup extends StatelessWidget {
  const DiscriptionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              Configs.instance.commonRadiusBottomSheet,
            ),
          ),
          child: Column(
            spacing: 10,
            children: [
              Text(
                context.l10n.discription,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              AssetsImages.images.imageCupid.image(width: 100),
              Text(
                context.l10n.discriptionSusgget,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              GradientButtonWidget(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.agree,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
