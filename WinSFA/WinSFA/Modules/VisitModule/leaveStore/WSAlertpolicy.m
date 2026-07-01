//
//  WSAlertpolicy.m
//  WinSFA
//
//  Created by winchannel on 15/8/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAlertpolicy.h"
#import "WSPolicyObject.h"

@implementation WSAlertpolicy

- (id)init{
    
    self = [super init];
    if (self) {
    
        
    }
    
    return self;
}
- (BOOL)testInMiniDuration:(NSInteger)duration fromBegin:(NSString *)beginDate toEnd:(NSString *)endDate{
    
    //获取近店时间
    NSDate *enterDate = [self getDate4TimeStr:beginDate];
    //离店时间
    NSDate *leaveDate =[self getDate4TimeStr:endDate];
    
    BOOL isinMinimumDuration = NO;
    
    
    //得到相差秒数
    NSTimeInterval time=[leaveDate timeIntervalSinceDate:enterDate];
    
    NSInteger minute = ((int)time)%(3600*24)/60;
    
    if (minute < duration) {
        
        isinMinimumDuration=YES;
    }
    return isinMinimumDuration;
    

}

- (NSDate *)getDate4TimeStr:(NSString *)timeStr{
    
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
   
    NSLog(@"========>>>>>>date: %@",date);
    
    return date;
}


- (void)executePolicy:(NSDictionary *)dict{
    
     WSPolicyObject *policyObject =  [self policyInfoMation4Dict:dict];
    
     BOOL isInDuration = [self testInMiniDuration:[policyObject duration]fromBegin:[policyObject begin_time_str] toEnd:[policyObject end_time_str]];
    
     if (isInDuration) {
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[policyObject title] message:[policyObject message] delegate:self.delegate cancelButtonTitle:@"cancel_label" otherButtonTitles:@"confirm", nil];
        
        [alert show];
    
    }
     else{
         
          [self.delegate alertpolicyforUpload];
     }
  
}

- (WSPolicyObject *)policyInfoMation4Dict:(NSDictionary *)policyDict{
    
    WSPolicyObject *policyObject =[[WSPolicyObject alloc]init];
    
    policyObject.begin_time_str = [policyDict objectForKey:@"begin_time_str"];
    
    policyObject.end_time_str = [policyDict objectForKey:@"end_time_str"];
    
 
    policyObject.duration = [[policyDict objectForKey:@"duration"] integerValue];
    
    policyObject.message = [policyDict objectForKey:@"message"];
    
    policyObject.title = [policyDict objectForKey:@"title"];
    
    return policyObject ;
    
}
@end
