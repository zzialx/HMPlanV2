//
//  WSNeighborPin.m
//  WinSFA
//
//  Created by Nemo on 14-3-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSNeighborPin.h"

@interface WSNeighborPin ()
{
  
}

@end

@implementation WSNeighborPin



- (id)initWithCoordinate2D:(CLLocationCoordinate2D)dinate
                    tittle:(NSString*)title subtitle:(NSString*)subtitle
{
    if(self = [super init])
    {
        _title = title;
        _subtitle=subtitle;
        _coordinate = dinate;
    }
    return self;
}

@end
