//
//  ProgressInd.h
//  NewSolution
//
//  Created by 李振杰 on 14-5-28.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//


#import "DACircularProgressView.h"
#import "WSWidget.h"

typedef enum{
    
    INVOLVE_STATUS_ADD,
    INVOLVE_STATUS_UNADD,
    INVOLVE_STATUS_FULL
    
}involvestatus;


@interface ProgressInd : WSWidget{
    
   
    UIImageView  *centerImage;
    
    DACircularProgressView   *processview;
    involvestatus status;
}

-(id)initWithFrameWithProcess:(CGRect)frame;

-(void)changeProgress:(float)progress andImg:(NSString *)imgname;

-(void)recovery;


-(void)changeCenterImage:(NSInteger)instatus;

@end
