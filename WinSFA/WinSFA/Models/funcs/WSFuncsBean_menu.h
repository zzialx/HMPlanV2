//
//  FuncsBean_menu.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSFuncsBean_menu : NSObject
{
    NSString *col;
    NSString *name;
    NSString *tpy;
    NSString *isplanlist;
    NSString *filter;
}

@property(nonatomic,strong) NSString *col;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *tpy;
@property (nonatomic, strong) NSString *isplanlist;
@property(nonatomic,strong) NSString *filter;

- (id)initFuncs_MenuWithObject:(id)object;

@end
