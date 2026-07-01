//
//  WSContactCell.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol I_W_ContactDisplay;
@protocol WSContactCellDelegate <NSObject>


@optional

-(void)sendInviteContact:(NSObject<I_W_ContactDisplay> *)contract addOrRemove:(BOOL)isadd;


@end

@interface WSContactCell : UITableViewCell{
    
    UILabel *contacname;
    
    UIImageView *white;
    
    UIImageView *gray;
    
    NSObject<I_W_ContactDisplay>  *contact;
    
    NSArray   *keys;
    
    __unsafe_unretained id<WSContactCellDelegate>  delegate;
    
}


@property (nonatomic,retain) UILabel *contacname;
@property (nonatomic,retain) UIImageView *white;
@property (nonatomic,retain) UIImageView *gray;

@property (nonatomic,retain) NSObject<I_W_ContactDisplay>  *contact;

@property (nonatomic,retain) NSArray   *keys;

@property (nonatomic,assign) id<WSContactCellDelegate>   delegate;

-(void)updateCell:(NSObject<I_W_ContactDisplay> *)contactx;

-(void)clearContent;

-(void)updateCellStatus:(BOOL)isuse;
-(void)setNoSelectedForSuccessInvited;

@end


