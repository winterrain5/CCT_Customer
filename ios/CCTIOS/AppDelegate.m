#import "AppDelegate.h"
#import <Stripe/Stripe-Swift.h>
#import <MobPush/MobPush.h>
#import <MOBFoundation/MobSDK.h>
#import <MOBFoundation/MobSDK+Privacy.h>
#import "CCTIOS-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  
  SwiftyFitsize.sharedSwiftyFitsize.referenceW = 375;
  StripeAPI.defaultPublishableKey = [[APIHost alloc] init].STRIPE_PK_LIVE;
  
//  [self configRootViewForRN:launchOptions];
  
  [ApplicationUtil configRootViewController];
  
  
  [self.window makeKeyAndVisible];
  
  [self setupNotification];
  
  return YES;
}

- (void)configRootViewForRN:(NSDictionary *)launchOptions {
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"CCTIOS"
                                            initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
  UIViewController *vc = [sb instantiateInitialViewController];
  rootView.loadingView = vc.view;
  MainViewController *rootViewController = [[MainViewController alloc] init];
  rootViewController.view = rootView;
  BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:rootViewController];
  self.window.rootViewController = nav;
}

- (void)setupNotification {
#ifdef DEBUG
  [MobPush setAPNsForProduction:NO];
#else
  [MobPush setAPNsForProduction:YES];
#endif
  
  //MobPush推送设置（获得角标、声音、弹框提醒权限）
  MPushNotificationConfiguration *configuration = [[MPushNotificationConfiguration alloc] init];
  configuration.types = MPushAuthorizationOptionsBadge | MPushAuthorizationOptionsSound | MPushAuthorizationOptionsAlert;
  [MobPush setupNotification:configuration];
  
  [MobPush setRegionID:0];
  [MobSDK registerAppKey:@"335ba928dd6e8" appSecret:@"d610c4befc4595f3c913a733f7a94769"];
  [MobPush getRegistrationID:^(NSString *registrationID, NSError *error) {
    NSLog(@"registrationID = %@--error = %@", registrationID, error);
  }];
  [MobSDK uploadPrivacyPermissionStatus:YES onResult:^(BOOL success) {
    NSLog(@"-------------->上传结果：%d",success);
  }];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MobPushDidReceiveMessageNotification object:nil];
  
}

// 收到通知回调
- (void)didReceiveMessage:(NSNotification *)notification
{
  MPushMessage *message = notification.object;
  
  // 推送相关参数获取示例请在各场景回调中对参数进行处理
  NSString *body = message.notification.body;
  NSString *title = message.notification.title;
  NSString *subtitle = message.notification.subTitle;
  NSInteger badge = message.notification.badge;
  NSString *sound = message.notification.sound;
  NSLog(@"收到通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge:%ld,\nsound:%@,\n}",body, title, subtitle, (long)badge, sound);
  
  switch (message.messageType)
  {
    case MPushMessageTypeCustom:
    {// 自定义消息回调
    }
      break;
    case MPushMessageTypeAPNs:
    {// APNs回调
    }
      break;
    case MPushMessageTypeLocal:
    {// 本地通知回调
      
    }
      break;
    case MPushMessageTypeClicked:
    {// 点击通知回调
      
    }
    default:
      break;
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  [MobPush clearBadge];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  
}


- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  self.url = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  self.url = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
  NSLog(@"source url: %@",self.url);
  return self.url;
}

@end
