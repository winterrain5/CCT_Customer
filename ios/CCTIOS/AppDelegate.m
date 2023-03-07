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
  
  [ApplicationUtil configRootViewController];
  
  
  [self.window makeKeyAndVisible];
  
  [self setupNotification];
  
  return YES;
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
#if DEBUG
  [MobSDK registerAppKey:@"377d12d0a74c4" appSecret:@"c55b8afb9de78321f527ec28676bb665"];
#else
  [MobSDK registerAppKey:@"335ba928dd6e8" appSecret:@"d610c4befc4595f3c913a733f7a94769"];
#endif
  
  [MobPush getRegistrationID:^(NSString *registrationID, NSError *error) {
    NSLog(@"registrationID = %@--error = %@", registrationID, error);
  }];
  [MobSDK uploadPrivacyPermissionStatus:YES onResult:^(BOOL success) {
    NSLog(@"-------------->上传结果：%d",success);
  }];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MobPushDidReceiveMessageNotification object:nil];
  
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  if (@available(iOS 13.0, *)) {
    NSString *token = [self getHexStringForData:deviceToken];
    NSLog(@"iOS 13之后的deviceToken的获取方式:%@",token);
  } else {
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"iOS 13之前的deviceToken的获取方式:%@",deviceTokenString);
  }
  
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
      [ApplicationUtil navgateToMessageController];
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
- (NSString *)getHexStringForData:(NSData *)data {
  NSUInteger len = [data length];
  char *chars = (char *)[data bytes];
  NSMutableString *hexString = [[NSMutableString alloc] init];
  for (NSUInteger i = 0; i < len; i ++) {
    [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
  }
  return hexString;
}

@end
