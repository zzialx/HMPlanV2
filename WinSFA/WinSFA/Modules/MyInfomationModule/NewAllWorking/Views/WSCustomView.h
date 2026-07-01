//
//  WSCustonView.h
//  WinSFA
//
//  Created by admin on 15/12/3.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSCustomViewExecuteSelectBtn <NSObject>

-(void)selectBtn:(UIButton * )btn;

@end

@interface WSCustomView : UIView

@property(nonatomic,weak) id <WSCustomViewExecuteSelectBtn> delegate;
-(id)initWithFrame:(CGRect)frame msgArray:(NSMutableArray *)msgArray  titleName:(NSString *)titleName;

@end
