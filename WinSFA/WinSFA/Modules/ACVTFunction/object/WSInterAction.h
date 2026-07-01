//
//  WSInterAction.h
//  WinSFA
//
//  Created by winchannel on 15/3/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    DIRECT_TYPE_PUSH,                    //从左向右推入 0
    DIRECT_TYPE_PRESENT,                 //从下向上推入 1
    DIRECT_TYPE_SHOW_IN_MAINVIEW,        //在主界面上进行显示 2
    DIRECT_TYPE_CLOASE_IN_MAINVIEW,      //从主界面上关闭,某种程度上的设计过量 3
    DIRECT_TYPE_METHOD_WITH_SINGLEPARAM, //调用方法（单个参数）。 4
    DIRECT_TYPE_SERVICE_METHOD, //请求调用某个服务的某个方法 5
    DIRECT_TYPE_DISMISS,             //从上往下消失 6
    DIRECT_TYPE_POPOVER,                 //iPad弹框形式
}DIRECT_TYPE;

@interface WSInterAction : NSObject{
    
    NSString  *acvt_qust_id;   //问题的编号
    
    DIRECT_TYPE  direct_type;  //跳转类型  0（viewcontroller push），1（viewcontroller present）
    
    NSString  *execute_class;   //执行类
    
    NSObject  *execute_class_param;  //执行类所需的参数
    
    NSObject  *execute_result;  //执行器类执行的结果对象
    
    NSObject  *execute_method_ns; //执行器的执行方法
    
    NSString  *inner_id; //内部id,一个32位guid类型
    
    NSObject  *inner_param; //内置参数
    
    NSString  *viewId; //内置viewId
    
    NSMutableDictionary  *env_context_setting; //当前环境上下文设置
    
    NSObject  *execute_class_param_title; // 标题
    
    
}

@property (nonatomic,strong) NSString  *acvt_qust_id;

@property (nonatomic,assign) DIRECT_TYPE  direct_type;

@property (nonatomic,strong) NSString  *execute_class;

@property (nonatomic,strong) NSString  *inner_id;

@property (nonatomic,strong) NSObject  *execute_class_param;

@property (nonatomic,strong) NSObject  *execute_class_param_title;

@property (nonatomic,strong) NSObject  *execute_result;

@property (nonatomic,strong) NSObject  *execute_method_ns;

@property (nonatomic,strong)  NSObject  *inner_param; //内置参数

@property (nonatomic,strong) NSString *viewId;

@property (nonatomic,strong) NSMutableDictionary  *env_context_setting; //当前环境上下文设置

// target controller
@property (nonatomic,weak) UIViewController *execute_controller;

@property (nonatomic,assign) SEL    execute_method; //执行方法

@property (nonatomic,strong) NSObject *execute_method_param;    //执行方法所需的参数

@property (nonatomic,strong)id excute_class_delegate;


-(void)setEnvValue:(NSObject *)value forKey:(NSString *)key;

-(NSObject *)getEnvValueForKey:(NSString *)key;


@end
