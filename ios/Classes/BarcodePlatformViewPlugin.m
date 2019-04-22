#import "BarcodePlatformViewPlugin.h"
#import <barcode_platform_view/barcode_platform_view-Swift.h>

@implementation BarcodePlatformViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBarcodePlatformViewPlugin registerWithRegistrar:registrar];
}
@end
