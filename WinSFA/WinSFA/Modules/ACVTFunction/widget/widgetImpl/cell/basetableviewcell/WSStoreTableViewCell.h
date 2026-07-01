//
//  WSStoreTableViewCell.h
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


#import "WSFunsShortCutPanel.h"
#import "WSFunsShortCutPanel.h"

@class WSOpenCloseBtn,WSStoreTableViewCell;

@protocol WSStoreTableViewCellDelegate <NSObject>

-(void)sendDetailInfo:(NSObject<I_W_Cell> *)obj;

- (void)selectListTableViewCell:(WSStoreTableViewCell *)cell  withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean;
@end

@interface WSStoreTableViewCell : UITableViewCell<WSFunsShortCutPanelDelegate>{
    
    UIImageView *status_btn;
    
    UILabel  *store_name_label;
    
    UIButton  *detailButton;
    
    WSFunsShortCutPanel *shortCutPanel;
    
    NSObject<I_W_Cell> *cell_info;
    

    
    __weak id<WSStoreTableViewCellDelegate>  delegate;
    
}

@property (nonatomic,weak) id<WSStoreTableViewCellDelegate>  delegate;

@property (nonatomic , strong) NSArray *shortCutArray;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellWidth:(CGFloat)width;

-(void)loadDisplayContent:(NSObject *)dataContent;

- (void)setTagFrame:(CGRect)cellRect
   withContentWidth:(CGFloat)contentWidth
        withContent:(NSString *)content
  withShortCutArray:(NSArray *)cutArray
             andRow:(int)row;

-(void)clearDataContent;

-(void)showAccessButton:(NSString *)showCode;

- (void)showShortCutPanel:(NSArray *)shortCutArray withStorBean:(WSStoreBean *)storeBean;


@end
