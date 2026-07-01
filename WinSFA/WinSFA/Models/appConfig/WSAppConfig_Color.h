//
//  AppConfig_Color.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_Color : NSObject
{
    NSString    *TextView_color;
    NSString    *CheckBox_color;
    NSString    *Gallery_color;
    NSString    *ListView_Color;
    NSString    *RadioButton_color;
    NSString    *empId;
}
@property (nonatomic, strong) NSString  *TextView_color;
@property (nonatomic, strong) NSString  *CheckBox_color;
@property (nonatomic, strong) NSString  *Gallery_color;
@property (nonatomic, strong) NSString  *ListView_color;
@property (nonatomic, strong) NSString  *RadioButton_color;
@property (nonatomic, strong) NSString  *empId;
- (id)initWithObject:(id)object;
@end
