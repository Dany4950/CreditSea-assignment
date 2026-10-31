import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/widgets/app_logo.dart';
import 'auth_slides.dart';
import 'auth_tokens.dart';

/// Blue header. With [pager] it is a live auto-sliding carousel (Create
/// Account); without it, it shows the fixed slide [page] (OTP = 1,
/// Password = 2). Wrapped in a RepaintBoundary and never rebuilt by the
/// keyboard.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.page = 0, this.pager});
  final int page;
  final PageController? pager;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: AuthTokens.primaryDark,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const AppLogo(),
                const SizedBox(height: 20),
                Expanded(
                  child: pager == null
                      ? _SlideView(slide: authSlides[page])
                      : PageView.builder(
                          controller: pager,
                          itemCount: authSlides.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, i) => _SlideView(slide: authSlides[i]),
                        ),
                ),
                const SizedBox(height: 8),
                pager == null
                    ? _StaticDots(active: page)
                    : SmoothPageIndicator(
                        controller: pager!,
                        count: authSlides.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                          spacing: 8,
                          activeDotColor: Colors.white,
                          dotColor: Color(0x66FFFFFF),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticDots extends StatelessWidget {
  const _StaticDots({required this.active});
  final int active;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < authSlides.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: i == active ? Colors.white : const Color(0x66FFFFFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SizedBox(width: i == active ? 24 : 8, height: 8),
              ),
            ),
        ],
      );
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final AuthSlide slide;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          slide.isGrid
              ? SizedBox(
                  width: 180,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (final i in slide.icons)
                        _IconTile(icon: i, size: 78, iconSize: 38, radius: 14),
                    ],
                  ),
                )
              : _IconTile(
                  icon: slide.icons.first,
                  watermark: slide.watermark,
                  size: 180,
                  iconSize: 76,
                  radius: 20,
                ),
          const SizedBox(height: 22),
          Text(slide.title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(slide.subtitle,
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.radius,
    this.watermark,
  });
  final IconData icon;
  final IconData? watermark;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(color: AuthTokens.tile, borderRadius: r),
      child: ClipRRect(
        borderRadius: r,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              if (watermark != null)
                Positioned(
                  right: -size * 0.08,
                  bottom: -size * 0.08,
                  child: Icon(watermark, size: size * 0.6, color: const Color(0x1FFFFFFF)),
                ),
              Center(child: Icon(icon, size: iconSize, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
