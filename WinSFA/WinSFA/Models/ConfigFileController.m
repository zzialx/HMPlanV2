//
//  ConfigFileController.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigFileController.h"

static ConfigFileController *configFileController = nil;

@implementation ConfigFileController
@synthesize ReadPlistFileDic = _ReadPlistFileDic;

+(ConfigFileController *)sharedInstanceMethod
{
    @synchronized(self) 
    {  
        if (configFileController == nil) 
        { 
           configFileController = [[self alloc] init];
        }
    }    
    return configFileController; 
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (configFileController == nil) {
            configFileController = [super allocWithZone:zone];
            return configFileController; 
        }
    }
    return nil; 
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//- (id)retain
//{
//    return self;
//}
//
//- (unsigned)retainCount 
//{
//    return NSUIntegerMax;  // denotes an object that cannot be released
//}
//
//- (id)autorelease {
//    return self;
//}



#pragma Mark 实例方法
-(NSDictionary *)getconfigFile
{
    NSString *configFileString=[[NSBundle mainBundle]pathForResource:@"ConfigFile" ofType:@"plist"];
    NSDictionary *configFileDic=[[NSDictionary alloc] initWithContentsOfFile:configFileString];
    return configFileDic;
}
#pragma  Mark Methods
-(NSString *)getValueForKey:(NSString *)key
{
    if (self.ReadPlistFileDic==nil) {
        self.ReadPlistFileDic=[[NSDictionary alloc]initWithDictionary:[self getconfigFile]];
        return [self.ReadPlistFileDic objectForKey:key];
    }
    return [self.ReadPlistFileDic objectForKey:key];
}

-(UIColor *) colorWithHexString: (NSString *)stringToConvert
{
    if ([stringToConvert isEqualToString:@""]) {
        return [UIColor colorWithWhite:(float)(0/255.0f) alpha:0.0f];
    }
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor colorWithRed:(float)(255/255.0f)green:(float)(255/255.0f)blue:(float)(255/255.0f)alpha:1.0f];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor colorWithRed:(float)(255/255.0f)green:(float)(255/255.0f)blue:(float)(255/255.0f)alpha:1.0f];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:(float)(r/255.0f)green:(float)(g/255.0f)blue:(float)(b/255.0f)alpha:1.0f];
}
-(NSString *)getCompleteURL:(NSString *)partOfURL
{
    NSString *SERVERString=[self.ReadPlistFileDic objectForKey:@"SERVER_IP"];
    NSString *ResultString=[SERVERString stringByAppendingString:partOfURL];
    return ResultString;
}
-(CGRect)getCGRectFromString:(NSString *)keyString
{
    CGRect cgRect=CGRectFromString([self.ReadPlistFileDic objectForKey:keyString]);
    return cgRect;
}
@end
