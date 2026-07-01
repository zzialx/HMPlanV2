//
//  SkillsAssessmentViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperWorkSpaceViewController.h"
#import "WSDictBean.h"
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSBaseGrideViewController.h"
#import "WSRequestHelper.h"
#import "WSCurrentTime.h"
#import "WSJSONBuilder.h"

@interface WSSkillsAssessmentViewController : WSBaseGrideViewController {}
@property (nonatomic, assign) int indexMarked;
@property (nonatomic, copy)NSString *srid;

@end
