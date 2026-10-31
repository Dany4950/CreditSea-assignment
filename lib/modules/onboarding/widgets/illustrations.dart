import 'package:flutter/material.dart';

// Flutter-drawn stand-ins. Replace with the Figma SVG exports via flutter_svg
// (assets/images/email_illustration.svg, pan_card.svg) when ready.

const _blue = Color(0xFF2D5CE0);
const _blueLight = Color(0xFF4F7BF0);
const _blob = Color(0xFFEFF3FF);

class EmailIllustration extends StatelessWidget {
  const EmailIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 160,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: _blob, shape: BoxShape.circle),
            child: SizedBox(width: 132, height: 132),
          ),
          Icon(Icons.mark_email_read_rounded, size: 64, color: _blue),
          Positioned(top: 14, right: 18, child: Icon(Icons.send_rounded, size: 20, color: _blueLight)),
          Positioned(left: 16, bottom: 22, child: Icon(Icons.alternate_email_rounded, size: 18, color: _blueLight)),
        ],
      ),
    );
  }
}

class PanCardIllustration extends StatelessWidget {
  const PanCardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 240,
      height: 155,
      child: Stack(
        children: [
          Positioned(
            left: 30,
            top: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _blob,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(90),
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(70),
                ),
              ),
              child: SizedBox(width: 170, height: 110),
            ),
          ),
          Positioned(left: 44, top: 44, child: _Card()),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: SizedBox(
        width: 166,
        height: 102,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_Chip(width: 46, height: 5), _Chip(width: 32, height: 16)],
              ),
              SizedBox(height: 8),
              _Chip(width: 28, height: 22),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Chip(width: 28, height: 8),
                  _Chip(width: 28, height: 8),
                  _Chip(width: 28, height: 8),
                  _Chip(width: 28, height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: _blueLight,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: SizedBox(width: width, height: height),
      );
}
