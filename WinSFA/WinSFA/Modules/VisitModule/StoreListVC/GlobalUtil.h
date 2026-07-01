//
//  GlobalUtil.h
//  TvBuy
//
//  Created by qianhe on 14/6/25.
//  Copyright (c) 2014年 Beijing CHSY E-Business Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ColorButton.h"
#import "MJRefreshGifHeader.h"
typedef NS_ENUM(NSInteger,TimeFormType)
{
    timeWithYearAndDay,   /* 年月日格式 */
    timeWithMothAndDay,   /* 月日格式 */
    timeWithDayAndHour,   /* 剩余时间 */
    timeWithDay,          /* 只返回天 */
    timeWithYearAndMonth, /* 返回年月*/
    timeWithSeconds       /* 返回秒 */
};
@interface GlobalUtil : NSObject
#pragma mark - 设置文本行间距
+ (NSAttributedString *)getAttributedStringWithString:(NSString *)textString withLineSpace:(CGFloat)lineSpace withFont:(UIFont *)font;
#pragma mark - textView限制字数
+ (void)textViewRestrictTextLengthWithTextView:(UITextView *)textView withLength:(int)length;
#pragma mark - JS参数解析
+ (NSDictionary *)getJSDicWithUrlString:(NSString *)urlString;
#pragma mark - 计算HTML文本高度
+ (NSString *)stringForHTMLText:(NSString *)htmlStr;
#pragma mark 时间戳转换成时间
+ (NSString *)timeOfTimestamp:(NSNumber *)timestamp withType:(TimeFormType)timeType;
+ (NSString *)timeWithYearOfTimestamp:(NSNumber *)timestamp;
//根据毫秒换算剩余时间
+ (NSString *)timeOfSurplusTimeMS:(long)ms withType:(TimeFormType)timeType;

#pragma mark 判断是否有网络
+(BOOL)networkIsPing;

#pragma mark 正则匹配手机号
+ (BOOL)validateMobileNumber:(NSString *)string;

#pragma mark 正则匹配纯数字 判断是是否是银行卡号
+ (BOOL)validateNumber:(NSString *)string;

#pragma mark 正则匹配邮政编码
+ (BOOL)validatePostCodeNumber:(NSString *)string;//

//判断是否含有除了字母和汉子意外的非法字符 yes 有  no没有
+ (BOOL)judgeTheillegalCharacter:(NSString *)content;

+ (BOOL)isChineseString:(NSString *)string;

#pragma mark 正则匹配——禁止输入中文且是6-16位之间非空格的任意字符
+ (BOOL)validatePassword:(NSString *)string;

+ (void)alertWithTitle:(NSString *)title msg:(NSString *)msg;

+ (BOOL)isEmpty:(NSString*)str;

//正则校验身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard;

+ (BOOL)isContainsEmoji:(NSString *)string;//判断字符串是否包含表情

+ (NSString *)filterEmoji:(NSString *)string;//筛选出表情


#pragma mark 代码创建纯色背景的按钮
//+ (ColorButton*)buttonWithTarget:(id)target action:(SEL)action title:(NSString*)title titleColor:(UIColor*)color frame:(CGRect)frame isWeiZone:(BOOL)isWeiZone;



#pragma mark 拨打电话
+ (void)callAndBack:(NSString *)phoneNum;

#pragma mark 判断是否是否有特殊字符
+ (BOOL)isHaveSpecialString:(NSString *)string;

//#pragma mark - 判断文字所占的size
//+ (CGSize)sizeOfContent:(NSString *)text labelFont:(UIFont *)font isFixWidth:(BOOL)isFix fixValue:(CGFloat)value;

#pragma mark - 自适应label宽度
+ (CGSize)P_adaptOfLabel:(CGSize )size WidthString:(NSString *)string Font:(UIFont *)font;
//根据字符串宽度得到字符串的高度
+ (CGFloat)getStringHeight:(UIFont *)font sting:(NSString *)string;
+ (CGFloat)getTextWidth:(UIFont *)font string:(NSString *)string;
#pragma mark - 设置部分字的字体和颜色
+ (NSMutableAttributedString *)setKeyWordTextStirng:(NSString *)KeyWord  withFont:(UIFont *)font AndColor:(UIColor *)color atTextString:(NSString *)textSting;

#pragma mark -设置button的image title color
+ (void)setButtonImage:(NSString *)imageName AndTitle:(NSString *)title atState:(UIControlState)state
         AndTitleColor:(NSString *)color AtButton:(UIButton *)button;

//数组排序
+ (NSMutableArray *)getOrderMNtableArray:(NSMutableArray*)MutArr;


#pragma mark - MBHUD

+ (MBProgressHUD *)MBHudshowAddTo:(UIView *)view isAfterDelay:(BOOL)after;
+ (MBProgressHUD *)MBHudshowCustomViewAddTo:(UIView *)view isAfterDelay:(BOOL)after;
+ (void)hideProgressHud:(UIViewController *)mainViewController;

#pragma mark-----TKAlertCenter
+ (void)showToastHintWithText:(NSString *)message;

#pragma mark - 从image里截取image
+ (UIImage *)cutImageFromImage:(UIImage *)originalImage withSize:(CGSize)cutSize;

#pragma mark - 从view里截取image
+ (UIImage *)cutImageFromView:(UIView *)view withSize:(CGSize)cutSize;
#pragma mark - 根据是否固定宽度计算相应宽高
+ (CGSize)sizeOfContent:(NSString *)text labelFont:(UIFont *)font isFixWidth:(BOOL)isFix fixValue:(CGFloat)value;
#pragma - mark 颜色填充
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
// 切圆角
+ (void)cutRoundView:(UIImageView *)imageView;
#pragma mark - 画虚线
// 返回虚线image的方法
+ (UIImage *)drawLineByImageView:(UIImageView *)imageView;
#pragma - mark Mj_refreshHeaderGif
+ (MJRefreshGifHeader *)headerMj_refreshGifImage:(id)target refreshingAction:(SEL)action;
/**
 *  操作完成提示
 *
 *  @param viewController
 *  @param title          完成提示(例如: 收藏成功, 删除成功)
 */
//+ (void)showCompleteOnController:(UIViewController *)viewController andTitle:(NSString *)title;

@end
