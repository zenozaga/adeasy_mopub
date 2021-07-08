#import "AdeasyMopubPlugin.h"
#if __has_include(<adeasy_mopub/adeasy_mopub-Swift.h>)
#import <adeasy_mopub/adeasy_mopub-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adeasy_mopub-Swift.h"
#endif

@implementation AdeasyMopubPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdeasyMopubPlugin registerWithRegistrar:registrar];
}
@end
