//
//  WSAppSettingModel.h
//  WinSFA
//
//  Created by Alicia on 2017/10/31.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    WSAppSettingDrawStyleNone,  //无样式
    WSAppSettingDrawStylePhone  //电话样式
}
WSAppSettingDrawStyle;          //绘制样式枚举

@interface WSAppSettingModel : NSObject

@property (nonatomic, copy) NSString *leftIconName;
@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, copy) NSString *rightCellMethodName;
@property (nonatomic, copy) NSString *selectMethodName;
@property (nonatomic, assign) WSAppSettingDrawStyle drawStylepe;

@end
