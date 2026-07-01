#import <UIKit/UIKit.h>

@interface ChineseToPinyin : NSObject {
    
}

+ (NSString *) pinyinFromChiniseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string; 
+ (NSString *)firstCharactorFromChiniseString:(NSString *)string;

+ (NSString *)getPinyinFromName:(NSString *)name;
@end
