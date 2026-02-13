import 'package:flutter/material.dart';
import 'widgets/duck_game_widget.dart';

/// Entry widget for the Duck Wars mini-game.
class DuckWarsPage extends StatelessWidget {
  const DuckWarsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(title: const Text('Vịt Trời — Duck Wars')),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              clipBehavior: Clip.hardEdge,
              child: const DuckGameWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
