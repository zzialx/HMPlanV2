//
//  WSPeopleContentView.h
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCellContentView.h"

@class WSPeopleContentView;

@protocol WSPeopleContentViewDelegate <NSObject>

@optional
-(void)generateURL:(WSPeopleContentView *)contentView;

@end

@interface WSPeopleContentView : WSCellContentView{    
    BOOL showAction;
}

@property (nonatomic,strong) UIButton* actionButton;

@property (nonatomic,assign) BOOL showAction;

@property (nonatomic,strong) WSStoreBean* currentStore;

@property (nonatomic, weak) id <WSPeopleContentViewDelegate> contentViewDelegate;

-(void)loadMediaInfo:(NSObject*)mediaInfo;

-(void)clearContent;

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)content;

- (void)pushWebControllerWithURL:(NSString*)url;
@end
