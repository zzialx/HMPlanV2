//
//  WSUpKeyBoardView.h
//  WinSFA
//
//  Created by zhangke on 15/1/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSUpKeyBoardView;
@protocol WSUpKeyBoardViewDelegate <NSObject>

@optional
-(void)closeOperation:(id)sender;

-(void)maginfiyOperation:(id)sender;

-(void)cancelOperation:(id)sender;

@end

@interface WSUpKeyBoardView : UIView{
    
    __unsafe_unretained  id<WSUpKeyBoardViewDelegate>  operationDelegate;
}

@property (nonatomic,assign) id<WSUpKeyBoardViewDelegate> operationDelegate;

@property (nonatomic, strong, readonly) UIButton *cancelButton;

@property (nonatomic, strong, readonly) UIButton *zoomInButton;

@property (nonatomic, strong, readonly) UIButton *finishButton;

@end
