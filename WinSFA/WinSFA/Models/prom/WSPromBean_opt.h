//
//  PromBean_opt.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSPromBean_opt : NSObject
                            // {
                            //    NSString *pid;
                            //    NSString *qid;
                            // }

@property (nonatomic, copy, readonly) NSString  *pid;
@property (nonatomic, copy, readonly) NSString  *qid;

- (id)initWithObject:(id)object;

@end
