//
//  WSRatingPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "RatingView.h"

@class RatingView;
@protocol RatingViewDelegate;

@interface WSRatingPanel : WSSingleTitlePanel<RatingViewDelegate>{
    
    RatingView *ratingView;
    
    float  currentrating;
    
}

@end
