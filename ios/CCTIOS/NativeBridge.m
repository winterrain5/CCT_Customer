//
//  NativeBridge.m
//  CCTIOS
//
//  Created by Derrick on 2021/12/30.
//

#import "NativeBridge.h"
#import "React/RCTBridge.h"
#import "CCTIOS-Swift.h"
@implementation NativeBridge
RCT_EXPORT_MODULE(NativeBridge)

RCT_EXPORT_METHOD(setUserId:(id)userId) {
  NSLog(@"setUserId:%@",userId);
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveUserId" object:userId];
  });
}

RCT_EXPORT_METHOD(setClientId:(id)clientId) {
  NSLog(@"setClientId:%@",clientId);
 
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveClientId" object:clientId];
  });
}

RCT_EXPORT_METHOD(setCompanyId:(id)companyId) {
  NSLog(@"setCompanyId:%@",companyId);
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveCompanyId" object:companyId];
  });
}

RCT_EXPORT_METHOD(setLoginPwd:(id)pwd) {
  NSLog(@"setLoginPwd:%@",pwd);
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveLoginPwd" object:pwd];
  });
}

RCT_EXPORT_METHOD(setBlogStatus:(NSString *)blogId bookMarked:(NSString *)bookMarked) {
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSDictionary *info = @{@"blogId":blogId,@"bookMarked":bookMarked};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBlogStatus" object:nil userInfo:info];
  });
  
}

RCT_EXPORT_METHOD(shareBlog:(NSString *)blogId title:(NSString *)title) {
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSDictionary *info = @{@"blogId":blogId,@"title":title};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shareBlog" object:nil userInfo:info];
  });
  
}



RCT_EXPORT_METHOD(openNativeVc:(NSString *)name params:(nullable  NSDictionary*)params) {
  NSLog(@"RN要调起的原生页面：%@ params:%@",name,params);
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openNativeVc" object:name userInfo:params];
  });
}

RCT_EXPORT_METHOD(openWebVc:(NSString *)url) {
  NSLog(@"RN要调起的原生页面：%@",url);
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openWebVc" object:url];
  });
}

RCT_EXPORT_METHOD(payment:(NSString *)json) {
  NSLog(@"payment：%@",json);
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"payment" object:json];
  });
}

RCT_EXPORT_METHOD(goBack) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goBackNativeVc" object:nil];
  });
}

RCT_EXPORT_METHOD(goBackToRootNativeVc) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goBackToRootNativeVc" object:nil];
  });
}



RCT_EXPORT_METHOD(log:(id)message) {
  NSLog(@"【React Native Log】%@",message);
}

RCT_EXPORT_METHOD(removeLocalData) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLocalData" object:nil];
  });
}


RCT_EXPORT_METHOD(showFilterView:(BOOL)isNew callback:(RCTResponseSenderBlock)callback) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [ShopFilterView show:isNew complete:^(NSString *result) {
      callback(@[[NSNull null],result]);
    }];
  });
}

RCT_EXPORT_METHOD(showLoading) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [Toast showLoading];
  });
  
}

RCT_EXPORT_METHOD(hideLoading) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [Toast dismiss];
  });
 
}

RCT_EXPORT_METHOD(showMessage:(id)message) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [Toast showMessage:message];
  });
}

RCT_EXPORT_METHOD(showSuccessWith:(id)message) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [Toast showSuccessWithStatus:message];
  });
  
}

RCT_EXPORT_METHOD(showErrorWith:(id)message) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [Toast showErrorWithStatus:message];
  });
}

RCT_EXPORT_METHOD(showPinView:(NSString *)pin callback:(RCTResponseSenderBlock)callback) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [CardDigitPinView showViewWithPin:pin confirmHandler:^(NSString * result) {
      callback(@[[NSNull null],result]);
    }];
  });
}

RCT_EXPORT_METHOD(showForgetPwdView) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [ForgetPwdSheetView show];
  });
}

RCT_EXPORT_METHOD(showPrivacyPolicyView) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [DataProtectionSheetView show];
  });
}

RCT_EXPORT_METHOD(showTermsConditionsView) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [TCApplyPrivilegesSheetView show];
  });
}

RCT_EXPORT_METHOD(callPhone:(NSString *)phone) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [CallUtil callPhone:phone];
  });
}

RCT_EXPORT_METHOD(callWhatsapp:(NSString *)whatsapp) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [CallUtil callWhatsapp:whatsapp];
  });
}


- (NSDictionary *)constantsToExport {
  
  return @{@"URL_API_HOST":[[APIHost alloc] init].URL_API_HOST,
           @"URL_API_IMAGE":[[APIHost alloc] init].URL_API_IMAGE,
           @"URL_BLOG_SHARE":[[APIHost alloc] init].URL_BLOG_SHARE,
           @"URL_API_UUID":[[APIHost alloc] init].URL_API_UUID,
           @"STRIPE_PK_LIVE":[[APIHost alloc] init].STRIPE_PK_LIVE
    };
}

@end
