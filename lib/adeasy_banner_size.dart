

class AdEasyBannerSize {

  const AdEasyBannerSize({required this.width, required this.height});
  final int width, height;


  static const AdEasyBannerSize MATCH =  AdEasyBannerSize(width: -1, height: -1);
  static const AdEasyBannerSize BANNER = AdEasyBannerSize(width: 320, height: 50);
  static const AdEasyBannerSize BANNER_TABLET = AdEasyBannerSize(width: 728, height: 90);
  static const AdEasyBannerSize MEDIUM_RECTANGLE =  AdEasyBannerSize(width: 336, height: 280);
  static const AdEasyBannerSize RECTANGLE =  AdEasyBannerSize(width: 300, height: 250);

}