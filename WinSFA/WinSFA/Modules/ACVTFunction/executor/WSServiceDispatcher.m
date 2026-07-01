//
//  WSServiceDispatcher.m
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSServiceDispatcher.h"
#import "WSInterAction.h"
#import "WSBaseService.h"
#import "I_W_BuildInfo.h"

@interface WSServiceDispatcher ()<WSBaseServiceDelegate>

@end
@implementation WSServiceDispatcher


-(id)init{
    self = [super init];
    
    if (self) {
        
        return self;
    }
    
    return nil;
}

-(void)executeDispatcher:(WSInterAction *)interaction{
    
    NSString  *executeClass = [interaction execute_class]; //执行的类名
    
    NSString  *executeMethod = (NSString *)[interaction execute_method_ns]; //执行的方法名
    
    NSObject *execute_class_method_param = [interaction execute_method_param];
    
    _baseservice =[[NSClassFromString(executeClass) alloc] init];
    
    self.baseservice.service_call_back_delegate = self;
    
    SEL callmethod = NSSelectorFromString(executeMethod);
    
    [self InvokenFunctionByName:callmethod instance:self.baseservice andSingleParam:execute_class_method_param];
    
}
#pragma mark -
#pragma mark WSBaseService method

//服务开始执行
-(void)serviceExecuteBegin:(WSBaseService *)baseService andResultObject:(NSObject *)object{
    
    
    if  ([self.dispatcherDelegate respondsToSelector:@selector(serviceBeginExecute:)]) {
        
         [self.dispatcherDelegate serviceBeginExecute:(WSInterAction *)object];
       
    }
    
}

//服务执行成功
-(void)serviceExecuteSuccessed:(WSBaseService *)baseService andResultObject:(NSObject *)object{
    
 
    if ([self.dispatcherDelegate respondsToSelector:@selector(serviceExecuteEnd:)]) {
        
        [self.dispatcherDelegate serviceExecuteEnd:(WSInterAction *)object];
    }
    

}

//服务执行中
-(void)serviceInExeute:(WSBaseService *)baseService andResultObject:(NSObject *)object{
    
    
    if ([self.dispatcherDelegate respondsToSelector:@selector(serviceInExecute:)]) {
        
        [self.dispatcherDelegate serviceInExecute:(WSInterAction *)object];
        
    }
    
}


-(void)serviceExecuteFailed:(WSBaseService *)baseService andResultObject:(NSObject *)object andError:(NSError *)error{
    
    if ([self.dispatcherDelegate respondsToSelector:@selector(serviceExecuteEndWithError:)]) {
        
        [self.dispatcherDelegate serviceExecuteEndWithError:(WSInterAction *)object];
        
    }
    
}



-(void)InvokenFunctionByName:(SEL)sel instance:(id)instance andSingleParam:(NSObject *)param {
    
        NSMethodSignature   *singlenature = [instance methodSignatureForSelector:sel];
        
        NSInvocation   *invocation = [NSInvocation invocationWithMethodSignature:singlenature];
        
        [invocation setTarget:instance];
        
        [invocation setSelector:sel];
        
        [invocation setArgument:&param atIndex:2];
        
        [invocation invoke];
    
}

@end
