//ReactRootViewManager.m
#import "ReactRootViewManager.h"
#import "AppDelegate.h"
@interface ReactRootViewManager ()
// 以 viewName-rootView 的形式保存需预加载的RN界面
@property (nonatomic, strong) NSMutableDictionary<NSString *, RCTRootView*> * rootViewMap;
@property (nonatomic, strong) NSURL *url;
@end

@implementation ReactRootViewManager

- (void)dealloc {
  _rootViewMap = nil;
  [_bridge invalidate];
}

+ (instancetype)shared {
  static ReactRootViewManager * _rootViewManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _rootViewManager = [[ReactRootViewManager alloc] init];
  });
  return _rootViewManager;
}

- (instancetype)init {
  if (self = [super init]) {
    _rootViewMap = [NSMutableDictionary dictionaryWithCapacity:0];
    _bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:nil];
  }
  return self;
}

- (void)preLoadRootViewWithName:(NSString *)viewName {
  [self preLoadRootViewWithName:viewName initialProperty:nil];
}

- (void)preLoadRootViewWithName:(NSString *)viewName initialProperty:(NSDictionary *)initialProperty {
  if (!viewName && [_rootViewMap objectForKey:viewName]) {
    return;
  }
  // 由bridge创建rootView 
  RCTRootView * rnView = [[RCTRootView alloc] initWithBridge:self.bridge
                                                  moduleName:viewName
                                           initialProperties:initialProperty];
  [_rootViewMap setObject:rnView forKey:viewName];
}

- (RCTRootView *)rootViewWithName:(NSString *)viewName {
  if (!viewName) {
    return nil;
  }
  
  return [self.rootViewMap objectForKey:viewName];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  self.url = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  self.url = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
  
  return self.url;
}



@end

