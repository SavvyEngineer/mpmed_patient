import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class empty_docs_widget extends StatelessWidget {
  const empty_docs_widget(this.contenet);
  final String contenet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        width: MediaQuery.of(context).size.width - 30,
        height: 150,
        isFrostedGlass: true,
        frostedOpacity: 0.05,
        blur: 20,
        elevation: 15,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.60),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.60),
          ],
          stops: [0.0, 0.45, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.0),
        child: Center(
          child: Text(contenet,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );
  }
}
