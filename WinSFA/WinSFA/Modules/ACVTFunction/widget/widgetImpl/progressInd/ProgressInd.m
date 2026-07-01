//
//  ProgressInd.m
//  NewSolution
//
//  Created by 李振杰 on 14-5-28.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//

#import "ProgressInd.h"


#import "WSConstant.h"




@implementation ProgressInd

-(id)initWithFrameWithProcess:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
      

        processview =[[DACircularProgressView alloc] initWithFrame:WSRect(0.0, 0.0, 104.0/2.0, 104.0/2.0)];
            
        [processview setTrackTintColor:[UIColor grayColor]];
        
        [self addSubview:processview];
            
        
    }
    return self;
}



-(void)changeProgress:(float)progress andImg:(NSString *)imgname{
 
    
    [processview setProgress:progress*0.01 animated:YES];
    

}

-(void)recovery{
    
      [processview setProgress:0.0 animated:YES];
    
}

-(void)changeCenterImage:(NSInteger)instatus{
    
    switch (instatus) {
            
        case INVOLVE_STATUS_FULL:
    
            break;
            
        default:
            break;
    }
    
}
@end
