//
//  GlobalUtil.m
//  TvBuy
//
//  Created by qianhe on 14/6/25.
//  Copyright (c) 2014年 Beijing CHSY E-Business Co., Ltd. All rights reserved.
//

#import "GlobalUtil.h"

@implementation GlobalUtil
#pragma mark - 设置文本行间距
+ (NSAttributedString *)getAttributedStringWithString:(NSString *)textString withLineSpace:(CGFloat)lineSpace withFont:(UIFont *)font
{
    //关于 f(x) = -(1.0/3 * x) - 1.0/3
    //offset是通过穷举法归纳总结出来的，也许不够准确，但在项目中用起来挺好。
    CGFloat offset = -(1.0/3 * lineSpace) - 1.0/3;
    CGFloat marginLeft = 15;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSDictionary *attrs = @{
                            NSFontAttributeName : font,
                            NSParagraphStyleAttributeName : paragraphStyle
                            };
    // 计算一行文本的高度
    CGFloat oneHeight = [@"测试Test" boundingRectWithSize:CGSizeMake(screenWidth-marginLeft*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    CGFloat rowHeight = [textString boundingRectWithSize:CGSizeMake(screenWidth-marginLeft*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    // 如果超出一行，则offset=0;
    offset = rowHeight > oneHeight ? 0 : offset;
    NSAttributedString *attributedString = [[self class]getAttributedStringWithString:textString lineSpace:lineSpace baselineOffset:offset];
    return attributedString;
}

+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace baselineOffset:(CGFloat)baselineOffset
{
    if (!string) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    // 设置文本偏移量
    [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset) range:range];
    return attributedString;
}

#pragma mark - textView限制字数
+ (void)textViewRestrictTextLengthWithTextView:(UITextView *)textView withLength:(int)length
{
    NSString *toBeString = textView.text;
    // 键盘输入模式(判断输入模式的方法是iOS7以后用到的,如果想做兼容,另外谷歌)
    NSArray * currentar = [UITextInputMode activeInputModes];
    UITextInputMode * current = [currentar firstObject];
    
    if ([current.primaryLanguage hasPrefix:@"zh-Hans"]) { // 简体中文输入,包括简体拼音,健体五笔,简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字,则对已输入的文字进行字数统计和限制
        if (!position) {
            
            if (toBeString.length >  length) {
                
                textView.text = [toBeString substringToIndex:length];
            }
            
        }else {
            // 有高亮选择的字符串,则暂不对文字进行统计和限制
        }
        
    }else {
        
        // 中文输入法以外的直接对其统计限制即可,不考虑其他语种情况
        if (toBeString.length > length) {
            textView.text = [toBeString substringToIndex:length];
        }
    }
}

#pragma mark - 计算HTML文本高度
+ (NSString *)stringForHTMLText:(NSString *)htmlStr
{
    NSString *strUrl = [htmlStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str1 = [strUrl stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    //    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
    //    NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    NSString *str4 = [str1 stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    NSString *str = [str4 stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
    
    return str;
}

+ (NSString *)timeOfTimestamp:(NSNumber *)timestamp withType:(TimeFormType)timeType
{
    NSString* timeString = [NSString stringWithFormat:@"%@",timestamp];
    NSTimeInterval time;
    if (timeString.length>9)
    {
        time =[[timeString substringToIndex:10] doubleValue];//因为时差问题要加8小时 == 28800 sec现在没加 等测试时候看效果
        
    }
    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    //  isEqualToString:@"timeWithDayAndHour"
    if (timeType == timeWithMothAndDay)
    {
        //不需要年的
        [formatter setDateFormat:@"MM-dd HH:mm"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    }
    
    if (timeType == timeWithYearAndDay)
    {
        //列表页任务开始时间 需要年的
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    }
    if (timeType == timeWithYearAndMonth)
    {
        //账户详情按月份排序
        [formatter setDateFormat:@"YYYY-MM"];
    }
    if (timeType == timeWithSeconds) {
        //账户详情 需要秒
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSString *dateStr = [formatter stringFromDate:detaildate];
    return dateStr;
}
//根据毫秒换算剩余时间
+ (NSString *)timeOfSurplusTimeMS:(long)ms withType:(TimeFormType)timeType
{
    int ss = 1000;
    int mi = ss*60;
    int hh = mi*60;
    int dd = hh*24;
    
    long day = ms/dd;
    long hour = (ms - day * dd) / hh;
    long minute = (ms - day * dd - hour * hh) / mi;
    long second = (ms - day * dd - hour * hh - minute * mi) / ss;
    //   long milliSecond = totalSeconds - day * dd - hour * hh - minute * mi - second * ss;
    
    NSString *strDay = day < 10 && day >= 0 ? [NSString stringWithFormat:@"%ld",day] : [NSString stringWithFormat:@"%ld",day]; //天
    NSString *strHour = hour < 10 ? [NSString stringWithFormat:@"0%ld",hour] : [NSString stringWithFormat:@"%ld",hour];//小时
    NSString *strMinute = minute < 10 ? [NSString stringWithFormat:@"0%ld",minute] :[NSString stringWithFormat:@"%ld",minute];//分钟
    NSString *strSecond = second < 10 ? [NSString stringWithFormat:@"0%ld",second] : [NSString stringWithFormat:@"%ld",second];//秒
    
    if (timeType == timeWithDayAndHour)
    {
        return [NSString stringWithFormat:@"剩余%2@天%2@小时%2@分%2@秒",strDay,strHour, strMinute, strSecond];
    }
    else if(timeType == timeWithDay)
    {
        return strDay;
    }else {
        return [NSString stringWithFormat:@"%2@天%2@小时%2@分",strDay,strHour, strMinute];
    }
}

+ (NSString *)timeWithYearOfTimestamp:(NSNumber *)timestamp
{
    NSString* timeString = [NSString stringWithFormat:@"%@",timestamp];
    NSTimeInterval time =[[timeString substringToIndex:10] doubleValue];//因为时差问题要加8小时 == 28800 sec现在没加 等测试时候看效果
    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"YY-MM-dd HH:mm"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    
    NSString *dateStr = [formatter stringFromDate:detaildate];
    // NSString *
    return dateStr;
}
#pragma mark 判断是否有网络
+(BOOL)networkIsPing
{
    BOOL isServerAvailable;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if (([reachability connectionRequired]) || (NotReachable == reachability.currentReachabilityStatus)) {
        isServerAvailable = NO;
        
    } else if((ReachableViaWiFi == reachability.currentReachabilityStatus) || (ReachableViaWWAN == reachability.currentReachabilityStatus)){
        isServerAvailable = YES;
    }
    return isServerAvailable;
    
}

#pragma mark 正则匹配手机号

+ (BOOL)validateMobileNumber:(NSString *)string
{
    if ([string isEqualToString:@"18838026157"]) {
        
    }
    static NSString *tempStr = @"^((\\+86)?|\\(\\+86\\))0?1\\d{10}$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if(numberofMatch > 0)
    {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)validatePostCodeNumber:(NSString *)string
{
    if (!string) {
        
        return NO;
    }
    static NSString *tempStr = @"^[1-9]\\d{5}$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if(numberofMatch > 0)
    {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - 判断字符串是否包含表情
+ (BOOL)isContainsEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}

#pragma mark - 筛选出表情
+ (NSString *)filterEmoji:(NSString *)string
{
    NSUInteger len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    const char *utf8 = [string UTF8String];
    
    char *newUTF8 = malloc( sizeof(char) * len );
    
    int j = 0;
    
    //0xF0(4) 0xE2(3) 0xE3(3) 0xC2(2) 0x30---0x39(4)
    
    for ( int i = 0; i < len; i++ )
    {
        unsigned int c = (unsigned int)utf8;
        
        BOOL isControlChar = NO;
        
        if ( c == 4294967280 ||
            c == 4294967089 ||
            c == 4294967090 ||
            c == 4294967091 ||
            c == 4294967092 ||
            c == 4294967093 ||
            c == 4294967094 ||
            c == 4294967095 ||
            c == 4294967096 ||
            c == 4294967097 ||
            c == 4294967088 ) {
            
            i = i + 3;
            
            isControlChar = YES;
            
        }
        
        if ( c == 4294967266 || c == 4294967267 )
        {
            i = i + 2;
            
            isControlChar = YES;
        }
        
        if ( c == 4294967234 )
        {
            i = i + 1;
            
            isControlChar = YES;
        }
        
        if ( !isControlChar )
        {
            newUTF8[j] = (char)utf8;
            
            j++;
        }
    }
    
    newUTF8[j] = '\0';
    
    NSString *encrypted = [NSString stringWithCString:(const char*)newUTF8
                                             encoding:NSUTF8StringEncoding];
    
    free( newUTF8 );
    
    return encrypted;
}


#pragma mark 正则匹配纯数字 
+ (BOOL)validateNumber:(NSString *)string{
    NSString *bankCardNumbeStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    static NSString *tempStr = @"^[0-9]+$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:bankCardNumbeStr options:NSMatchingReportProgress range:NSMakeRange(0, bankCardNumbeStr.length)];
    if(numberofMatch > 0 && bankCardNumbeStr.length>15 && bankCardNumbeStr.length < 20 )
    {
        return YES;
    }else{
        return NO;
    }
}

//判断是否含有非法字符 yes 有  no没有 名字验证 新疆可以有·这个符号
+ (BOOL)judgeTheillegalCharacter:(NSString *)content{
    //提示 标签不能输入特殊字符
    NSString *str =@"^[·A-Za-z\\u4e00-\u9fa5]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:content] || content.length<2) {
        return YES;
    }
    return NO;
}

+(BOOL)validatePassword:(NSString *)string
{
    
    static NSString *tempStr = @"^[^\\s\u4e00-\u9fa5]{6,16}$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if(numberofMatch > 0)
    {
        return YES;
    }else{
        return NO;
    }
}

+ (void)alertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (BOOL)isEmpty:(NSString*)str
{
    if ([str isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if (str == nil || [str length] == 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark 代码创建纯色背景的按钮
//+ (ColorButton*)buttonWithTarget:(id)target action:(SEL)action title:(NSString*)title titleColor:(UIColor*)color frame:(CGRect)frame isWeiZone:(BOOL)isWeiZone
//{
//    NSMutableArray *colorArray = nil;
//    if (isWeiZone)
//    {
//        colorArray = [@[[UIColor colorWithRed:255/255.0 green:97/255.0 blue:19/255.0 alpha:1.0],[UIColor colorWithRed:254/255.0 green:32/255.0 blue:36/255.0 alpha:1.0]] mutableCopy];
//    }else
//    {
//        colorArray = [@[RGB_COLOR(k_Button_Color),RGB_COLOR(k_Button_Color)] mutableCopy];
//    }
//    
//    ColorButton *btn = [[ColorButton alloc]initWithFrame:frame FromColorArray:colorArray ByGradientType:topToBottom];
//    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    return btn;
//}
//


+ (void)callAndBack:(NSString *)phoneNum {
    //    NSString *phoneNum = @"10086";// 电话号码
    
    //number为号码字符串 如果使用这个方法 结束电话之后会进入联系人列表
    //NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",phoneNum];
    
    //而这个方法则打电话前先弹框  是否打电话 然后打完电话之后回到程序中 网上说这个方法可能不合法 无法通过审核
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",phoneNum];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
}

#pragma mark 判断是否是否有特殊字符
+ (BOOL)isHaveSpecialString:(NSString *)string
{
    static NSString *tempStr = @"^[\u4E00-\u9FA5A-Za-z0-9，。,.-_- ]+$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if(numberofMatch > 0)
    {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark 判断是否是汉字且2到4汉字
+ (BOOL)isChineseString:(NSString *)string
{
    static NSString *tempStr = @"^[\u4E00-\u9FA5]{2,4}$";
    //  static NSString *tempStr = @"^[\u4E00-\u9FA5]{2,}$";不限制长度
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]initWithPattern:tempStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if(numberofMatch > 0)
    {
        return YES;
    }else{
        return NO;
    }
    
}

#pragma mark - 从image里截取image
+ (UIImage *)cutImageFromImage:(UIImage *)originalImage withSize:(CGSize)cutSize
{
    //************** 得到图片 *******************
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    imageView.image = originalImage;
    CGRect rect = imageView.frame;  //截取图片大小
    
    //开始取图，参数：截图图片大小
    UIGraphicsBeginImageContext(rect.size);
    //截图层放入上下文中
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    //从上下文中获得图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束截图
    UIGraphicsEndImageContext();
    
    //*************** 截取小图 ******************
    if (rect.size.width >= cutSize.width && rect.size.height >= cutSize.height) {
        CGRect cutRect = CGRectMake((rect.size.width - cutSize.width) / 2.0, (rect.size.height - cutSize.height) / 2.0, cutSize.width, cutSize.height);//创建矩形框
        //对图片进行截取
        UIImage * cutImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], cutRect)];
        return cutImage;
    }
    return originalImage;
}

#pragma mark - 从view里截取image
+ (UIImage *)cutImageFromView:(UIView *)view withSize:(CGSize)cutSize
{
    //************** 得到图片 *******************
    CGRect rect = view.frame;  //截取图片大小
    
    //开始取图，参数：截图图片大小
    UIGraphicsBeginImageContext(rect.size);
    //截图层放入上下文中
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //从上下文中获得图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束截图
    UIGraphicsEndImageContext();
    
    //*************** 截取小图 ******************
    if (rect.size.width >= cutSize.width && rect.size.height >= cutSize.height) {
        CGRect cutRect = CGRectMake((rect.size.width - cutSize.width) / 2.0, (rect.size.height - cutSize.height) / 2.0, cutSize.width, cutSize.height);//创建矩形框
        //对图片进行截取
        UIImage * cutImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], cutRect)];
        return cutImage;
    }
    return image;
}

#pragma mark - 判断文字所占的size
+ (CGSize)sizeOfContent:(NSString *)text labelFont:(UIFont *)font isFixWidth:(BOOL)isFix fixValue:(CGFloat)value
{
    CGSize size = CGSizeZero;
    if (isFix) {
        size = CGSizeMake(value, MAXFLOAT);
    }else{
        size = CGSizeMake(MAXFLOAT, value);
    }
    CGSize actualsize = CGSizeZero;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    if (IOS7_OR_LATER) {
        actualsize = [text boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    }else{
        //TODO
        actualsize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    }
    if (!(text.length>0))
    {
        actualsize.height = 0;
    }
    return actualsize;
}
//+ (void)showCompleteOnController:(UIViewController *)viewController andTitle:(NSString *)title
//{
//    if (HUD) {
//        return;
//    }
//    if ([title isEqualToString:@"接口调用失败，请联系技术人员"]) {
//        title = L(@"interface error");
//    }
//    HUD = [MBProgressHUD showHUDAddedTo:viewController.navigationController.view animated:YES andType:MBProgressHUDNativeYES];
//    [viewController.navigationController.view addSubview:HUD];
//    
//    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
//    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]] ;
//    
//    // Set custom view mode
//    HUD.mode = MBProgressHUDModeCustomView;
//    HUD.labelText = title;
//    HUD.userInteractionEnabled = YES;
//    [HUD show:YES];
//    [HUD hide:YES afterDelay:1.5];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        HUD = nil;
//    });
//}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//正则校验身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard
{
    //    BOOL flag;
    //    if (identityCard.length <= 0) {
    //        flag = NO;
    //        return flag;
    //    }
    //    //230803199203290316
    //    NSString *regex2 = @"^(\\d{17})(\\d|[xX])$";
    //    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    //    return [identityCardPredicate evaluateWithObject:identityCard];
    
    
    identityCard = [identityCard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([identityCard length] != 18)
    {
        return NO;
    }
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|8[1-2]|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![regexTest evaluateWithObject:identityCard]) {
        return NO;
    }
    int summary = ([identityCard substringWithRange:NSMakeRange(0,1)].intValue + [identityCard substringWithRange:NSMakeRange(10,1)].intValue) *7
    + ([identityCard substringWithRange:NSMakeRange(1,1)].intValue + [identityCard substringWithRange:NSMakeRange(11,1)].intValue) *9
    + ([identityCard substringWithRange:NSMakeRange(2,1)].intValue + [identityCard substringWithRange:NSMakeRange(12,1)].intValue) *10
    + ([identityCard substringWithRange:NSMakeRange(3,1)].intValue + [identityCard substringWithRange:NSMakeRange(13,1)].intValue) *5
    + ([identityCard substringWithRange:NSMakeRange(4,1)].intValue + [identityCard substringWithRange:NSMakeRange(14,1)].intValue) *8
    + ([identityCard substringWithRange:NSMakeRange(5,1)].intValue + [identityCard substringWithRange:NSMakeRange(15,1)].intValue) *4
    + ([identityCard substringWithRange:NSMakeRange(6,1)].intValue + [identityCard substringWithRange:NSMakeRange(16,1)].intValue) *2
    + [identityCard substringWithRange:NSMakeRange(7,1)].intValue *1 + [identityCard substringWithRange:NSMakeRange(8,1)].intValue *6
    + [identityCard substringWithRange:NSMakeRange(9,1)].intValue *3;
    NSInteger remainder = summary % 11;
    NSString *checkBit = @"";
    NSString *checkString = @"10X98765432";
    checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
    return [checkBit isEqualToString:[[identityCard substringWithRange:NSMakeRange(17,1)] uppercaseString]];
}

// 切圆角
+ (void)cutRoundView:(UIImageView *)imageView
{
    CGFloat corner = imageView.frame.size.width / 2;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(corner, corner)];
    shapeLayer.path = path.CGPath;
    imageView.layer.mask = shapeLayer;
}

#pragma mark - 自适应label宽度
+ (CGSize)P_adaptOfLabel:(CGSize )size WidthString:(NSString *)string Font:(UIFont *)font
{
    CGRect rect = [string  boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil];
    
    CGSize mysize = CGSizeMake(rect.size.width, rect.size.height);
    return mysize;
}

#pragma mark - 计算宽高
+ (CGFloat)getStringHeight:(UIFont *)font sting:(NSString *)string{
    
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    return size.height;
}

+ (CGFloat)getTextWidth:(UIFont *)font string:(NSString *)string
{
    CGSize size = [string boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size;
    return size.width;
}


#pragma mark - 设置部分字的字体和颜色
+ (NSMutableAttributedString *)setKeyWordTextStirng:(NSString *)KeyWord  withFont:(UIFont *)font AndColor:(UIColor *)color atTextString:(NSString *)textSting
{
    NSRange range = [textSting rangeOfString:KeyWord];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:textSting];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    [str addAttribute:NSFontAttributeName value:font range:range];
    return  str;
}

#pragma mark -设置button的image title color
+ (void)setButtonImage:(NSString *)imageName AndTitle:(NSString *)title atState:(UIControlState)state
         AndTitleColor:(NSString *)color AtButton:(UIButton *)button;
{
    [button setImage:[UIImage imageNamed:imageName] forState:state];
    [button setTitle:title forState:state];
    [button setTitleColor:RGB_COLOR(color) forState:state];
}



+ (NSMutableArray *)getOrderMNtableArray:(NSMutableArray*)MutArr//数组里存字典,按大到小排序
{
    if (MutArr.count)
    {
        for (int i=0; i<MutArr.count-1; i++)
        {
            for (int j=0; j<MutArr.count-1-i; j++)
            {
                NSDictionary *dict1=MutArr[j];
                NSDictionary *dict2=MutArr[j+1];
                NSString *str1=[[dict1 allKeys] objectAtIndex:0];
                NSString *str2=[[dict2 allKeys] objectAtIndex:0];
                if ([str1 intValue]<[str2 intValue])
                {
                    [MutArr exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                }
            }
        }
    }
    return MutArr;
}

#pragma mark - 画虚线
// 返回虚线image的方法
+ (UIImage *)drawLineByImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.frame.size); //开始画线 划线的frame
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    //设置线条终点形状
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapButt);
    // 5是每个虚线的长度 1是高度
    CGFloat lengths[] = {6,1};
    CGContextRef line = UIGraphicsGetCurrentContext();
    // 设置颜色
    CGContextSetStrokeColorWithColor(line, RGB_COLOR(@"#ffffff").CGColor);
    CGContextSetLineDash(line, 0, lengths, 1); //画虚线
    CGContextMoveToPoint(line, 0.0, 1.0); //开始画线
    CGContextAddLineToPoint(line, SCREEN_WIDTH - 10, 1.0);
    
    CGContextStrokePath(line);
    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (MJRefreshGifHeader *)headerMj_refreshGifImage:(id)target refreshingAction:(SEL)action
{
    
    NSMutableArray * imagesArray = [NSMutableArray array];
    for (int i = 1; i < 29; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d",i]];
        [imagesArray addObject:image];
    }
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:target refreshingAction:action];
    // 设置普通状态的动画图片
    
    [header setImages:imagesArray forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    
    [header setImages:imagesArray forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    
    [header setImages:imagesArray forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    //  header.backgroundColor = RGB_COLOR(k_ViewBack_Color);
    
    // 隐藏状态
    
    header.stateLabel.hidden = YES;
    return header;
    
}

@end
