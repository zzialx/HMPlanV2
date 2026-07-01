//
//  WSGridWidgetFactory.h
//  WinSFA
//
//  Created by Alicia on 2018/6/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSGridWidget.h"

@interface WSGridWidgetFactory : NSObject

+ (id)shareInstance;

- (WSGridWidget *)createGridWidgetByParam:(WSFuncsBean_Param *)param rowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)colIndex;

@end
