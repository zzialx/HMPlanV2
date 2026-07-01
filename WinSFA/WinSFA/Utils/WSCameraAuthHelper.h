//
//  WSCameraAuthHelper.h
//  WinSFA
//
//  Created by Alicia on 2017/9/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^authDoneBlock)(BOOL isOK);

@interface WSCameraAuthHelper : NSObject

- (void)authCameraWithBlock:(authDoneBlock)doneBlock;

@end
