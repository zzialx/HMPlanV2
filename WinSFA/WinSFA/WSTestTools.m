//
//  WSTestTools.m
//  WinSFA
//
//  Created by xiajl on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTestTools.h"

#define DEBUG_OPEN 0

@interface WSTestTools ()

@property (nonatomic ,strong) NSMutableDictionary *timesDictionary;

@end

@implementation WSTestTools

 __strong static WSTestTools *sharedInstance = nil;

+ (instancetype) getInstance
{
    static dispatch_once_t onceToken = 0;
   
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WSTestTools alloc] init];
    });
    
    return sharedInstance;

}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (nil == sharedInstance) {
            sharedInstance = [super allocWithZone:zone];
        }
        return sharedInstance;
    }
    
    return nil;
}

-(id)copy
{
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;    //如果未MRC，个人感觉应该使用 [self retain]
}

#if __has_feature(objc_arc)
#else
- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return 1;
}

- (oneway void) release
{
    // Do nothing
}

- (id) autorelease
{
    return self;
}
#endif


#pragma mark - public method

- (void)keepTimeWithKey:(NSString*)key
{
    [self keepTimeWithKey:key forcePrint:NO];
}

- (void)keepTimeWithKey:(NSString *)key forcePrint:(BOOL)forcePrint
{
    BOOL result = NO;
    
    if (forcePrint) {
        result = YES;
    }
    
#if DEBUG_OPEN
    result = YES;
#endif
    
    if (result) {
        if (!self.timesDictionary) {
            self.timesDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self setStartTime:[NSDate date] forKey:key];
    }
}

- (void)setStartTime:(NSDate*)date forKey:(NSString *) keyString
{
    [self.timesDictionary setValue:date forKey:keyString];
     LogInfo(@"=== %@ === 开始计时" ,keyString);
}


- (void)printAndEndTimeIntervalforKey:(NSString *) keyString
{
    [self printAndEndTimeIntervalforKey:keyString forcePrint:NO];
}

- (void)printAndEndTimeIntervalforKey:(NSString *)keyString forcePrint:(BOOL)forcePrint
{
    
    BOOL result = NO;
    
    if (forcePrint) {
        result = YES;
    }
    
#if DEBUG_OPEN
    result = YES;
#endif
    
    
    if (result) {
        id object = [self.timesDictionary objectForKey:keyString];
        if ([object isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)object;
            LogInfo(@"=== %@ === 结束计时，耗时 === %f ===" ,keyString,[date  timeIntervalSinceNow]);
            [self.timesDictionary removeObjectForKey:keyString];
        }else{
            
            LogInfo(@"计时keyString is null ！！！");
        }
        [self.timesDictionary removeObjectForKey:keyString];
    }
}



@end
