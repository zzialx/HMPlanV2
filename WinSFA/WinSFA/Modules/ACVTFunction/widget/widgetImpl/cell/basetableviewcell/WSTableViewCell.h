//
//  WSTableViewCell.h
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"

@class  WSCellContentView;

@protocol WSWidgetDelegate;

@interface WSTableViewCell : UITableViewCell<WSWidgetDelegate>{
    
    
    WSCellContentView  *cellcontentview;
    
    __unsafe_unretained  id<WSWidgetDelegate>   cell_delegate;
    
    NSString   *acvt_type;
    
    NSMutableDictionary  *key_type_dict;
    
    NSMutableArray  *cellcontents;
    
    NSMutableDictionary  *cellViewConfig;
    
}

@property (nonatomic,strong) NSString  *acvt_type;

@property (nonatomic,assign) id<WSWidgetDelegate>   cell_delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andAcvtType:(NSString *)acvt_typein;

-(void)clearDisplayContent;

-(void)setCellContent:(NSMutableArray *)cellcontentsin;

-(void)loadDisplayContent:(NSObject *)contentobject;

-(WSCellContentView *)getContentView;

-(void)showActionButton;

@end
