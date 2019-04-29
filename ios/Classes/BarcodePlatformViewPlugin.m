#import "BarcodePlatformViewPlugin.h"
#import "FlutterBarcodeScan.h"

@implementation BarcodePlatformViewPlugin
// + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//   [SwiftBarcodePlatformViewPlugin registerWithRegistrar:registrar];
// }
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterBarcodeScanFactory* barcodeScanFactory =
      [[FlutterBarcodeScanFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:barcodeScanFactory withId:@"barcodescanner"];
}
@end

