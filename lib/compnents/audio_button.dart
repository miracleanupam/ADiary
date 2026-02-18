import 'package:flutter/material.dart';

class AudioButton extends StatelessWidget {
  final bool showRecorder;
  final Function fn;
  const AudioButton({super.key, required this.showRecorder, required this.fn});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => fn(),
        style: ElevatedButton.styleFrom(
            side: BorderSide(color: Colors.pink.shade200, width: 1),
            backgroundColor: Colors.pink.shade100,
            foregroundColor: Colors.pink.shade900,
            iconColor: Colors.pink.shade900,
            iconSize: 24,
            textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'IndieFlower')),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(showRecorder ? Icons.edit : Icons.mic),
            SizedBox(
              width: 5,
            ),
            Text(showRecorder ? 'Edit journal' : 'Record an andio too????!!'),
          ],
        ));
  }
}
