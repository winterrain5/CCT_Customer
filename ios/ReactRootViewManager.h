#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>

@interface ReactRootViewManager : NSObject<RCTBridgeDelegate>

// 全局唯一的bridge
@property (nonatomic, strong, readonly) RCTBridge * bridge;

+ (instancetype)shared;

/*
 * 根据viewName预加载bundle文件
 * param:
 *     viewName RN界面名称
 *     initialProperty: 初始化参数
 */
- (void)preLoadRootViewWithName:(NSString *)viewName;
- (void)preLoadRootViewWithName:(NSString *)viewName initialProperty:(NSDictionary *)initialProperty;

/*
 * 根据viewName获取rootView
 * param:
 *     viewName RN界面名称
 *
 * return: 返回匹配的rootView
 */
- (RCTRootView *)rootViewWithName:(NSString *)viewName;

@end
