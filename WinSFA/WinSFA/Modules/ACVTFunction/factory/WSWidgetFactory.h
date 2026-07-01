//
//  WSAcvtFactory.h
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class  WSWidget;

@protocol I_W_BuildInfo;

@interface WSWidgetFactory : NSObject{
    
    
    NSMutableDictionary    *mapping_dict; //映射字典
    
    
}


/**
 * @brief 静态方法，获取WSWidgetFactory的实例.
 *
 * @param  frame CGRect.
 *
 * @return void.
 */
+(id)shareInstance;

-(WSWidget *)createWidgetByWidgetInfo:(NSObject<I_W_BuildInfo> *)widgetInfo;


@end
