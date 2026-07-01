//
//  WSServiceDispatcher.h
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSInterAction;
@class WSBaseService;

@protocol WSServiceDispatcherDelegate <NSObject>

@optional

-(void)serviceInExecute:(WSInterAction *)interaction;

-(void)serviceBeginExecute:(WSInterAction *)interaction;

-(void)serviceExecuteEnd:(WSInterAction *)interaction;

-(void)serviceExecuteEndWithError:(WSInterAction *)interaction;

@end



@interface WSServiceDispatcher : NSObject{
    
}


@property (nonatomic,strong)WSBaseService  *baseservice;
@property (nonatomic,weak) id<WSServiceDispatcherDelegate>  dispatcherDelegate;





-(void)executeDispatcher:(WSInterAction *)interaction;


@end
