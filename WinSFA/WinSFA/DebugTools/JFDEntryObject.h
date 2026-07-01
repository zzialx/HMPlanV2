//
//  JFDEntryObject.h
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFDEntryObject : NSObject

@property (nonatomic, strong) NSString  *debugServerIp;
@property (nonatomic, strong) NSString  *debugWebServer;

+ (JFDEntryObject*) getInstance;
- (void) addDebugToolsToViewController:(UIViewController*)vc
                             withFrame:(CGRect)rect;

- (void) removeDebutTools;

//外部不可调用下面方法
-(void)exchangeAndsetDebugServerIp:(NSString *)debugServerIp;
//+ (NSString *)debugCompleteURL:(NSString *)partOfURL;

@end
