//
//  WSSMSDetailCell.h
//  WinSFA
//
//  Created by mac on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSSMSManagerModel;
@class WSMappingObject;


typedef NS_ENUM(NSInteger,WSSMSDetailCellType){
    
    WSSMSDetailCellTypeGroup,
    WSSMSDetailCellTypeDetail,

};


@interface WSSMSDetailCell : UITableViewCell

@property (nonatomic,nullable , strong) id  model;

@property (nullable , copy) void (^buttonClick)();

+(CGFloat)cellHeightWith:(nullable id)model;
+(CGFloat)detailLableSize:(nullable id)model;
-initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier type:(WSSMSDetailCellType)type;
@end
