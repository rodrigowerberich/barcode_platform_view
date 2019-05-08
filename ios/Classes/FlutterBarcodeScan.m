#import "FlutterBarcodeScan.h"

@interface ScannerOverlay()
@property(nonatomic, retain) UIView *line;
@end

@implementation ScannerOverlay

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColor.redColor;
        _line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_line];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor * overlayColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55];
    UIColor *scanLineColor = UIColor.redColor;
    
    CGContextSetFillColorWithColor(context, overlayColor.CGColor);
    CGContextFillRect(context, self.bounds);
    
    // make a hole for the scanner
    CGRect holeRect = [self scanRect];
    CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
    [[UIColor clearColor] setFill];
    UIRectFill(holeRectIntersection);
    
    // draw a horizontal line over the middle
    CGRect lineRect = [self scanLineRect];
    _line.frame = lineRect;
    
    // drw the green corners
    CGFloat cornerSize = 30;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //top left corner
    [path moveToPoint:CGPointMake(holeRect.origin.x, holeRect.origin.y + cornerSize)];
    [path addLineToPoint:CGPointMake(holeRect.origin.x, holeRect.origin.y)];
    [path addLineToPoint:CGPointMake(holeRect.origin.x + cornerSize, holeRect.origin.y)];
    
    //top right corner
    CGFloat rightHoleX = holeRect.origin.x + holeRect.size.width;
    [path moveToPoint:CGPointMake(rightHoleX - cornerSize, holeRect.origin.y)];
    [path addLineToPoint:CGPointMake(rightHoleX, holeRect.origin.y)];
    [path addLineToPoint:CGPointMake(rightHoleX, holeRect.origin.y + cornerSize)];
    
    // bottom right corner
    CGFloat bottomHoleY = holeRect.origin.y + holeRect.size.height;
    [path moveToPoint:CGPointMake(rightHoleX, bottomHoleY - cornerSize)];
    [path addLineToPoint:CGPointMake(rightHoleX, bottomHoleY)];
    [path addLineToPoint:CGPointMake(rightHoleX - cornerSize, bottomHoleY)];
    
    // bottom left corner
    [path moveToPoint:CGPointMake(holeRect.origin.x + cornerSize, bottomHoleY)];
    [path addLineToPoint:CGPointMake(holeRect.origin.x, bottomHoleY)];
    [path addLineToPoint:CGPointMake(holeRect.origin.x, bottomHoleY - cornerSize)];
    
    path.lineWidth = 2;
    [[UIColor greenColor] setStroke];
    [path stroke];
    
}

- (void)startAnimating {
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:0.0];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.25;
    flash.autoreverses = YES;
    flash.repeatCount = HUGE_VALF;
    [_line.layer addAnimation:flash forKey:@"flashAnimation"];
}

- (void)stopAnimating {
    [self.layer removeAnimationForKey:@"flashAnimation"];
}

- (CGRect)scanRect {
    CGRect rect = self.frame;
    CGFloat heightMultiplier = 3.0/4.0; // 4:3 aspect ratio
    CGFloat scanRectWidth = rect.size.width * 0.8f;
    CGFloat scanRectHeight = scanRectWidth * heightMultiplier;
    CGFloat scanRectOriginX = (rect.size.width / 2) - (scanRectWidth / 2);
    CGFloat scanRectOriginY = (rect.size.height / 2) - (scanRectHeight / 2);
    return CGRectMake(scanRectOriginX, scanRectOriginY, scanRectWidth, scanRectHeight);
}

- (CGRect)scanLineRect {
    CGRect scanRect = [self scanRect];
    CGRect rect = self.frame;
    return CGRectMake(scanRect.origin.x, rect.size.height / 2, scanRect.size.width, 1);
}

@end

@implementation FlutterBarcodeScanFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  FlutterBarcodeScanController* barcodeScanController =
      [[FlutterBarcodeScanController alloc] initWithWithFrame:frame
                                       viewIdentifier:viewId
                                            arguments:args
                                      binaryMessenger:_messenger];
  return barcodeScanController;
}

@end

@implementation FlutterBarcodeScanController {
  int64_t _viewId;
  FlutterMethodChannel* _channel;
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ([super init]) {
    _viewId = viewId;
    printf("Height %f Width %f\n", frame.size.height, frame.size.width);
    self.previewView = [[UIView alloc] initWithFrame:frame];
    self.previewView.backgroundColor = [UIColor clearColor];
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanRect = [[ScannerOverlay alloc] initWithFrame:frame];
    self.scanRect.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanRect.backgroundColor = UIColor.clearColor;
    [ self.previewView addSubview: self.scanRect ];
      [self.previewView addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"V:[scanRect]"
                                 options:NSLayoutFormatAlignAllBottom
                                 metrics:nil
                                 views:@{@"scanRect": _scanRect}]];
      [self.previewView addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:[scanRect]"
                                 options:NSLayoutFormatAlignAllBottom
                                 metrics:nil
                                 views:@{@"scanRect": _scanRect}]];
//    [_scanRect startAnimating];
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.previewView];
    NSString* channelName = [NSString stringWithFormat:@"barcodescanner_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      [weakSelf onMethodCall:call result:result];
    }];

  }
  return self;
}

- (UIView*)view {
  return self.previewView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"startCamera"]) {
        printf("scanRect start animating\n");
        [_scanRect startAnimating];
     [self onStartCamera:call result:result];
    }else if ([[call method] isEqualToString:@"stopCamera"]) {
        [self.scanner stopScanning];
    }else if ([[call method] isEqualToString:@"setDimensions"]) {
        float new_width = [call.arguments[@"width"] floatValue];
        float new_height = [call.arguments[@"height"] floatValue];
        self.previewView.frame = CGRectMake(self.previewView.frame.origin.x, self.previewView.frame.origin.y, new_width, new_height);
    }else {
    result(FlutterMethodNotImplemented);
   }
}

 - (void)onStartCamera:(FlutterMethodCall*)call result:(FlutterResult)result {
     if (self.scanner.isScanning) {
         [self.scanner stopScanning];
     }
     [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
         if (success) {
             NSError *error;
             printf("Will scan!\n");
             [self.scanner startScanningWithResultBlock:^(NSArray<AVMetadataMachineReadableCodeObject *> *codes) {
                 printf("Found something\n");
                 [self.scanner stopScanning];
                 AVMetadataMachineReadableCodeObject *code = codes.firstObject;
                 if (code) {
                     NSLog(@"%@", code.stringValue);
                     [self->_channel invokeMethod:@"valueScanned" arguments: code.stringValue];
                     //             [self.delegate barcodeScannerViewController:self didScanBarcodeWithResult:code.stringValue];
                     //             [self dismissViewControllerAnimated:NO completion:nil];
                 }
             } error:&error];
         } else {
              // Communicate failure
         }
     }];
 }

@end
