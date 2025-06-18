class OnboardingData {
  final String image;
  final String titleKey;
  final String subtitleKey;

  OnboardingData({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    image: 'assets/images/image 1.png',
    titleKey: 'onboarding_title_1',
    subtitleKey: 'onboarding_subtitle_1',
  ),
  OnboardingData(
    image: 'assets/images/image 6.png',
    titleKey: 'onboarding_title_2',
    subtitleKey: 'onboarding_subtitle_2',
  ),
  OnboardingData(
    image: 'assets/images/image 7.png',
    titleKey: 'onboarding_title_3',
    subtitleKey: 'onboarding_subtitle_3',
  ),
];
