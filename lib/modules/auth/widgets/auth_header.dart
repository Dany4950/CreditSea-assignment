import 'package:creditsea/core/widgets/app_logo_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'auth_slides.dart';
import 'auth_tokens.dart';

/// Blue header. With [pager] it is a live auto-sliding carousel.
/// Without it, it shows the fixed slide [page].
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.page = 0,
    this.pager,
  });

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

                const AppLogoText(),

                const SizedBox(height: 20),

                Expanded(
                  child: pager == null
                      ? _SlideView(
                          slide: authSlides[page],
                        )
                      : PageView.builder(
                          controller: pager,
                          itemCount: authSlides.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, index) {
                            return _SlideView(
                              slide: authSlides[index],
                            );
                          },
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

/// Static indicator used when there is no PageController.
class _StaticDots extends StatelessWidget {
  const _StaticDots({
    required this.active,
  });

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < authSlides.length; i++)
          Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 8,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: i == active
                    ? Colors.white
                    : const Color(0x66FFFFFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SizedBox(
                width: i == active ? 24 : 8,
                height: 8,
              ),
            ),
          ),
      ],
    );
  }
}

/// Individual onboarding/auth slide.
class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
  });

  final AuthSlide slide;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Multiple visuals → Grid
          slide.isGrid
              ? SizedBox(
                  width: 180,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      for (final visual in slide.visuals)
                        _VisualTile(
                          visual: visual,
                          size: 78,
                          visualSize: 38,
                          radius: 14,
                        ),
                    ],
                  ),
                )

              /// Single visual → Large tile
              : _VisualTile(
                  visual: slide.visuals.first,
                  watermark: slide.watermark,
                  size: 180,
                  visualSize: 76,
                  radius: 20,
                ),

          const SizedBox(height: 22),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile supporting both Material Icons and image assets.
///
/// - Icon: shown centered inside the colored tile.
/// - Image: fills the complete tile.
class _VisualTile extends StatelessWidget {
  const _VisualTile({
    required this.visual,
    required this.size,
    required this.visualSize,
    required this.radius,
    this.watermark,
  });

  final AuthVisual visual;
  final AuthVisual? watermark;

  final double size;
  final double visualSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    /// IMAGE → Fill the complete tile.
    if (visual.isImage) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            visual.imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const ColoredBox(
                color: AuthTokens.tile,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    /// ICON → Show inside the colored tile.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthTokens.tile,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              /// Optional watermark.
              if (watermark != null)
                Positioned(
                  right: -size * 0.08,
                  bottom: -size * 0.08,
                  child: _buildWatermark(
                    watermark!,
                    size: size * 0.6,
                  ),
                ),

              /// Main icon.
              Center(
                child: Icon(
                  visual.icon,
                  size: visualSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatermark(
    AuthVisual watermark, {
    required double size,
  }) {
    /// Icon watermark.
    if (watermark.isIcon) {
      return Icon(
        watermark.icon,
        size: size,
        color: const Color(0x1FFFFFFF),
      );
    }

    /// Image watermark.
    if (watermark.isImage) {
      return Opacity(
        opacity: 0.12,
        child: Image.asset(
          watermark.imagePath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}