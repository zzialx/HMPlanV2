//
//  ZYCalendarViewFlowLayout.m
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import "ZYCalendarViewFlowLayout.h"

@implementation ZYCalendarViewFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    }
    
    return self;
}
@end
