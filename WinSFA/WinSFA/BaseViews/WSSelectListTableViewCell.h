//
//  WSSelectListTableViewCell.h
//  WinSFA
//
//  Created by xiajl on 14-9-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFunsShortCutPanel.h"
#import "WSFuncsBean.h"

typedef enum{
	ECELLTAGStyleNone = 1,
	ECELLTAGStyleInPlan,
	ECELLTAGStyleOutPlan
}ECELLTAGStyle;

@class WSSelectListTableViewCell;

@protocol WSSelectListTableViewCellDelegate <NSObject>

- (void)selectListTableViewCell:(WSSelectListTableViewCell *)cell  withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean;

@end

@interface WSSelectListTableViewCell : UITableViewCell<UINavigationControllerDelegate,WSFunsShortCutPanelDelegate>{
    
    UILabel  *detail_label;
    
}
@property (nonatomic , strong) UILabel *mainTxtLabel;
@property (nonatomic , strong) UILabel *subTxtLabel;
@property (nonatomic , strong) UIImageView *visitStateView;
@property (nonatomic , strong) UIButton *detailButton;
@property (nonatomic , strong) NSArray *funsBeanArray;

@property (nonatomic , strong) WSFunsShortCutPanel *shortCutPanel;

@property (nonatomic , weak) id<WSSelectListTableViewCellDelegate>delegate;

/**
 *
 *
 *  @param cellRect
 *  @param tagStyle
 */
- (void) setTagFrame:(CGRect)cellRect andStyle:(ECELLTAGStyle)tagStyle;

-(void)hiddenImageButton:(BOOL)hidden;

-(void)showAccessButton:(NSString *)showCode;

- (void)showShortCutPanelData:(WSStoreBean *)storeBean
       withShortCutFuncsArray:(NSArray *)cutfuncsArray;


-(void)clearDataContent;
@end
