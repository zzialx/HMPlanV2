#import <UIKit/UIKit.h>

#define KDEAISellFloatWindowWidth 60.0f
#define KDEAISellFloatWindowHeight 60.0f
#define KDEAISellFloatWindowBottomSpace 70.0f
#define KDEAISellFloatWindowRightSpace 0

typedef NS_OPTIONS(NSUInteger, WSSellFloatWindowType) {
    WSSellFloatWindowTypeNormal = 1 << 0,//仅悬浮
    WSSellFloatWindowTypeSupportPortraitPan = 1 << 1,//支持竖屏滑动
    WSSellFloatWindowTypeSupportLandscapePan = 1 << 2,//支持横屏滑动
    WSSellFloatWindowTypeSupportPortraitSpringToBounds = 1 << 3, //支持竖屏弹至边框
    WSSellFloatWindowTypeSupportLandscapeSpringToBounds = 1 << 4, //支持横屏弹至边框
};

typedef NS_OPTIONS(NSUInteger, BoundaryType) {
    BoundaryTypeLeft = 1 << 0,
    BoundaryTypeRight = 1 << 1,
};

@interface WSSellFloatWindow : UIWindow

@property(nonatomic,assign)BOOL isShowMenu;


@property (nonatomic, assign) WSSellFloatWindowType floatType;

@property (nonatomic, copy) void(^clickAction)(void);

//-(id)initWithFrame:(CGRect)frame imageName:(NSString*)name;
@end
