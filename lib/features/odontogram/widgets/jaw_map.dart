import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/odontogram_provider.dart';
import 'tooth_item.dart';

class JawMap extends StatelessWidget {
  const JawMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upper Jaw',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            // We split the jaw into left and right to make it look somewhat arched
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  children: provider.upperJaw.sublist(0, 8).reversed.map((t) => ToothItem(toothNumber: t.number, isUpper: true)).toList(),
                ),
                const SizedBox(width: 16), // Midline
                Wrap(
                  children: provider.upperJaw.sublist(8, 16).map((t) => ToothItem(toothNumber: t.number, isUpper: true)).toList(),
                ),
              ],
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  children: provider.lowerJaw.sublist(0, 8).reversed.map((t) => ToothItem(toothNumber: t.number, isUpper: false)).toList(),
                ),
                const SizedBox(width: 16), // Midline
                Wrap(
                  children: provider.lowerJaw.sublist(8, 16).map((t) => ToothItem(toothNumber: t.number, isUpper: false)).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Lower Jaw',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
          ],
        );
      },
    );
  }
}
