#import <React/RCTBridgeDelegate.h>
#import <UIKit/UIKit.h>
#import "CCTIOS-Swift.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCTBridgeDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSURL *url;
@end
