//
//  WSScheduleStore.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-5-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSScheduleStore.h"

#define WSSCHEDULESTORE_DATE        @"ws_schedule_store_date"
#define WSSCHEDULESTORE_IDS         @"ws_schedule_store_ids"

@implementation WSScheduleStore

-(id)init
{
    self = [super init];
    if (self) {
        _ids = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: self.date forKey:WSSCHEDULESTORE_DATE];
    [aCoder encodeObject: self.ids forKey:WSSCHEDULESTORE_IDS];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
	if (self)
    {
        self.date = [aDecoder decodeObjectForKey: WSSCHEDULESTORE_DATE];
        self.ids = [aDecoder decodeObjectForKey: WSSCHEDULESTORE_IDS];
	}
	
	return self;
}

@end
