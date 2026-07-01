//
//  PayDisPlayBean.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-26.
//
//

#import <Foundation/Foundation.h>

#define PAYDISPLAY_MAIN_ID      @"main_id"
#define PAYDISPLAY_SID          @"sid"
#define PAYDISPLAY_PID          @"pid"
#define PAYDISPLAY_ID           @"id"
#define PAYDISPLAY_NAME         @"name"
#define PAYDISPLAY_STARTTIME    @"startTime"
#define PAYDISPLAY_ENDTIME      @"endTime"

@interface PayDisPlayBean : NSObject

@property (nonatomic, copy, readonly) NSString *main_id;
@property (nonatomic, copy, readonly) NSString *sid;
@property (nonatomic, copy, readonly) NSString *pid;
@property (nonatomic, copy, readonly) NSString *Id;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *startTime;
@property (nonatomic, copy, readonly) NSString *endTime;

@property (nonatomic, strong, readonly) NSArray *inArray;

- (id)initWithObject:(id)object;

@end
