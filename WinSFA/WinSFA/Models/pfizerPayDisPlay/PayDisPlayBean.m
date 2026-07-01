//
//  PayDisPlayBean.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-26.
//
//

#import "PayDisPlayBean.h"
#import "NSDictionary+Additional.h"

@implementation PayDisPlayBean

@synthesize main_id = _main_id;
@synthesize sid = _sid;
@synthesize pid = _pid;
@synthesize Id = _Id;
@synthesize name = _name;
@synthesize inArray = _inArray;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (id)initWithObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary *)object;
        _main_id = [[dic getStringValueWithKeyName:PAYDISPLAY_MAIN_ID] copy];
        _sid = [[dic getStringValueWithKeyName:PAYDISPLAY_SID] copy];
        _pid = [[dic getStringValueWithKeyName:PAYDISPLAY_PID] copy];
        _Id = [[dic getStringValueWithKeyName:PAYDISPLAY_ID] copy];
        _name = [[dic getStringValueWithKeyName:PAYDISPLAY_NAME] copy];
        _startTime = [[dic getStringValueWithKeyName:PAYDISPLAY_STARTTIME] copy];
        _endTime = [[dic getStringValueWithKeyName:PAYDISPLAY_ENDTIME] copy];
        
        
        NSArray *array = [object objectForKey:@"in"];
        if (array) {
            NSMutableArray *subBeanArray = [NSMutableArray arrayWithCapacity:[array count]];
            for (NSDictionary *subDic in array) {
                PayDisPlayBean *bean = [[PayDisPlayBean alloc] initWithObject:subDic];
                if (bean) {
                    [subBeanArray addObject:bean];
                }
            }
            _inArray = [[NSArray alloc] initWithArray:subBeanArray];
        }
        
    }
    return self;
}

@end
