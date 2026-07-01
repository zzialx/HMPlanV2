//
//  WSMessageDetailFileCell.h
//  WinSFA
//
//  Created by mac on 17/2/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseTableViewCell.h"
#define cell_Height_For_Row (INTERFACE_IS_PHONE ? 64 : 70)

@class WSMsgsBean_Component_msg;
@class WSMsgContentMediaView;
@interface WSMessageDetailFileCell : WSBaseTableViewCell

@property (nonatomic , copy) NSString *fileName;
@property (nonatomic , strong) WSMsgsBean_Component_msg *component_Msg;
@property(nonatomic , strong) WSMsgContentMediaView * iconImgView;

@end
