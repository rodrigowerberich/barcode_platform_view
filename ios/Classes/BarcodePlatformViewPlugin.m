#import "BarcodePlatformViewPlugin.h"
#import <barcode_platform_view/barcode_platform_view-Swift.h>

@implementation BarcodePlatformViewPlugin
// + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//   [SwiftBarcodePlatformViewPlugin registerWithRegistrar:registrar];
// }
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterNativeBarcodeScanFactory* barcodeScanFactory =
      [[FlutterNativeBarcodeScanFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:barcodeScanFactory withId:@"barcodescanner"];
}
@end

