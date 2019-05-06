#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>
#import <MTBBarcodeScanner/MTBBarcodeScanner.h>

@interface ScannerOverlay : UIView
@property(nonatomic) CGRect scanLineRect;

- (void) startAnimating;
- (void) stopAnimating;
@end

@interface FlutterBarcodeScanController : NSObject <FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;
//@property(nonatomic, retain) UIView *mainView;
@property(nonatomic, retain) UIView *previewView;
@property(nonatomic, retain) ScannerOverlay *scanRect;
@property(nonatomic, retain) MTBBarcodeScanner *scanner;
@end

@interface FlutterBarcodeScanFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
