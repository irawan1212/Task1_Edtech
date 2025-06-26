import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/onboarding/onboarding_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData onboardingData;

  const OnboardingPage({
    super.key,
    required this.onboardingData,
  });

  // Helper function untuk mendapatkan responsive content position
  double _getContentTopPosition(Size screenSize) {
    final screenHeight = screenSize.height;

    if (screenHeight < 700) {
      return screenHeight * 0.58; // Smaller screens - position content higher
    } else if (screenHeight < 800) {
      return screenHeight * 0.6; // Medium screens
    } else if (screenHeight < 900) {
      return screenHeight * 0.62; // Large screens
    } else {
      return screenHeight * 0.64; // Extra large screens
    }
  }

  // Helper function untuk mendapatkan responsive padding
  double _getResponsivePadding(Size screenSize) {
    if (screenSize.width < 360) {
      return 16;
    } else if (screenSize.width < 400) {
      return 20;
    } else {
      return 24;
    }
  }

  // Helper function untuk mendapatkan responsive title font size
  double _getResponsiveTitleSize(Size screenSize) {
    if (screenSize.width < 360) {
      return 20;
    } else if (screenSize.width < 400) {
      return 22;
    } else if (screenSize.width < 450) {
      return 24;
    } else {
      return 26;
    }
  }

  // Helper function untuk mendapatkan responsive subtitle font size
  double _getResponsiveSubtitleSize(Size screenSize) {
    if (screenSize.width < 360) {
      return 14;
    } else if (screenSize.width < 400) {
      return 15;
    } else {
      return 16;
    }
  }

  // Helper function untuk mendapatkan responsive spacing antara title dan subtitle
  double _getResponsiveSpacing(Size screenSize) {
    if (screenSize.height < 700) {
      return 10;
    } else if (screenSize.height < 800) {
      return 12;
    } else {
      return 14;
    }
  }

  // Helper function untuk mendapatkan responsive image flex
  int _getImageFlex(Size screenSize) {
    final screenHeight = screenSize.height;

    if (screenHeight < 700) {
      return 5; // Smaller screens - reduce image area
    } else if (screenHeight < 800) {
      return 6; // Medium screens
    } else {
      return 6; // Large screens
    }
  }

  // Helper function untuk mendapatkan responsive content flex
  int _getContentFlex(Size screenSize) {
    final screenHeight = screenSize.height;

    if (screenHeight < 700) {
      return 5; // Smaller screens - increase content area
    } else if (screenHeight < 800) {
      return 4; // Medium screens
    } else {
      return 4; // Large screens
    }
  }

  // Helper function untuk mendapatkan responsive border radius
  double _getResponsiveBorderRadius(Size screenSize) {
    if (screenSize.width < 360) {
      return 35;
    } else if (screenSize.width < 400) {
      return 40;
    } else {
      return 45;
    }
  }

  // Helper function untuk memformat text menjadi 2 baris
  String _formatTextTo2Lines(String text, double fontSize, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    // Jika text sudah pas 2 baris atau lebih, return as is
    if (textPainter.didExceedMaxLines ||
        textPainter.computeLineMetrics().length == 2) {
      return text;
    }

    // Jika text hanya 1 baris, tambahkan line break di tengah
    final words = text.split(' ');
    if (words.length == 1) {
      // Jika hanya 1 kata, tambahkan baris kosong
      return '$text\n ';
    }

    final midPoint = (words.length / 2).ceil();
    final firstLine = words.take(midPoint).join(' ');
    final secondLine = words.skip(midPoint).join(' ');

    return '$firstLine\n$secondLine';
  }

  // Helper function untuk memformat text menjadi 3 baris (updated)
  String _formatTextTo3Lines(String text, double fontSize, double maxWidth) {
    final words = text.split(' ');

    // Jika tidak ada kata, return 3 baris kosong
    if (words.isEmpty) {
      return ' \n \n ';
    }

    String result = '';
    int wordIndex = 0;

    // Buat tepat 3 baris
    for (int line = 0; line < 3; line++) {
      String currentLine = '';

      // Tambahkan kata-kata sampai baris penuh atau kata habis
      while (wordIndex < words.length) {
        final testLine = currentLine.isEmpty
            ? words[wordIndex]
            : '$currentLine ${words[wordIndex]}';

        final testPainter = TextPainter(
          text: TextSpan(
            text: testLine,
            style: TextStyle(fontSize: fontSize),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        );

        testPainter.layout(maxWidth: maxWidth);

        // Jika menambahkan kata ini akan melampaui lebar, stop
        if (testPainter.didExceedMaxLines && currentLine.isNotEmpty) {
          break;
        }

        currentLine = testLine;
        wordIndex++;
      }

      // Jika baris kosong (kata habis), isi dengan spasi
      if (currentLine.isEmpty) {
        currentLine = ' ';
      }

      // Tambahkan ke result
      if (line < 2) {
        result += '$currentLine\n';
      } else {
        result += currentLine;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    final responsivePadding = _getResponsivePadding(screenSize);
    final responsiveTitleSize = _getResponsiveTitleSize(screenSize);
    final responsiveSubtitleSize = _getResponsiveSubtitleSize(screenSize);
    final responsiveSpacing = _getResponsiveSpacing(screenSize);
    final responsiveBorderRadius = _getResponsiveBorderRadius(screenSize);
    final contentTopPosition = _getContentTopPosition(screenSize);
    final imageFlex = _getImageFlex(screenSize);
    final contentFlex = _getContentFlex(screenSize);

    // Format title text menjadi 2 baris
    final maxTitleWidth = screenSize.width - (responsivePadding * 2);
    final formattedTitle = _formatTextTo2Lines(
      l10n.translate(onboardingData.titleKey),
      responsiveTitleSize,
      maxTitleWidth,
    );

    // Format subtitle text menjadi 3 baris
    final maxSubtitleWidth = screenSize.width - (responsivePadding * 2);
    final formattedSubtitle = _formatTextTo3Lines(
      l10n.translate(onboardingData.subtitleKey),
      responsiveSubtitleSize,
      maxSubtitleWidth,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              // Background layout with responsive flex
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      flex: imageFlex,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(responsiveBorderRadius),
                          bottomRight: Radius.circular(responsiveBorderRadius),
                        ),
                        child: Image.asset(
                          onboardingData.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback widget jika gambar tidak ditemukan
                            return Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(flex: contentFlex, child: const SizedBox()),
                  ],
                ),
              ),
              // Content overlay with responsive positioning
              Positioned(
                top: contentTopPosition,
                left: responsivePadding,
                right: responsivePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title dengan 2 baris tetap
                    SizedBox(
                      height: responsiveTitleSize *
                          2.5, // Fixed height untuk 2 baris
                      child: Text(
                        formattedTitle,
                        textAlign: TextAlign.center,
                        style: AppTheme.headingStyle(size: responsiveTitleSize),
                      ),
                    ),
                    SizedBox(height: responsiveSpacing),
                    // Subtitle dengan 3 baris tetap
                    SizedBox(
                      height: responsiveSubtitleSize *
                          3.8, // Fixed height untuk 3 baris
                      child: Text(
                        formattedSubtitle,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style:
                            AppTheme.contentStyle(size: responsiveSubtitleSize),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
