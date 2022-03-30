//
//  PushManager.m
//  CCTIOS
//
//  Created by Derrick on 2022/1/20.
//

#import "PushManager.h"

#define PaymentStatus @"PaymentStatus"
#define BlogBookMarkStatus @"BlogBookMarkStatus"
#define OpenRNPage @"OpenRNPage"
#define UserDataChanged @"UserDataChanged"
#define ChangeAPI @"ChangeAPI"


#define NATIVE_ONNOFIFICATION @"native_onNotification"

@implementation PushManager

RCT_EXPORT_MODULE()

-(NSArray*)supportedEvents {
  
  return @[PaymentStatus,OpenRNPage,BlogBookMarkStatus,UserDataChanged];
  
}

- (void)nativeSendNotificationToRN:(NSNotification*)notification {
  
  NSLog(@"NativeToRN notification.object = %@", notification.object);
  NSString *type = notification.userInfo[@"type"];
  NSString *body = (NSString *)notification.object;
  dispatch_async(dispatch_get_main_queue(), ^{
    
    if ([type isEqual:PaymentStatus]) {
      [self sendEventWithName:PaymentStatus body:body];
    }
    
    if ([type isEqual:OpenRNPage]) {
      [self sendEventWithName:OpenRNPage body:body];
    }
    
    if ([type isEqual:BlogBookMarkStatus]) {
      [self sendEventWithName:BlogBookMarkStatus body:body];
    }
    
    if ([type isEqual:UserDataChanged]) {
      [self sendEventWithName:UserDataChanged body:body];
    }
    
    if ([type isEqual:ChangeAPI]) {
      [self sendEventWithName:ChangeAPI body:body];
    }
  });
  
}

- (void)startObserving {
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(nativeSendNotificationToRN:)
                                               name:NATIVE_ONNOFIFICATION
                                             object:nil];
  
}

- (void)stopObserving {
  
  [[NSNotificationCenter defaultCenter]removeObserver:self name:NATIVE_ONNOFIFICATION object:nil];
  
}

@end

