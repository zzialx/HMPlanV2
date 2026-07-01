//
//  AppConfig_Color.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_Color.h"
#import "WinSFA.h"
@implementation WSAppConfig_Color
@synthesize TextView_color;
@synthesize ListView_color;
@synthesize RadioButton_color;
@synthesize CheckBox_color;
@synthesize Gallery_color;
@synthesize empId;

-(id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            TextView_color = [dic objectForKey:APPCONFIG_TEXTVIEW_COLOR];
            Gallery_color = [dic objectForKey:APPCONFIG_GALLERY_COLOR];
            ListView_color = [dic objectForKey:APPCONFIG_LISTVIEW_COLOR];
            RadioButton_color = [dic objectForKey:APPCONFIG_RADIOBUTTON_COLOR];
            CheckBox_color = [dic objectForKey:APPCONFIG_CHECKBOX_COLOR];
            empId = [dic objectForKey:APPCONFIG_EMPID];
        }
    }
    
    return self;
}


@end
