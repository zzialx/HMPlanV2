//
//  WSDetailFileDownLoadView.h
//  WinSFA
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMessageDetailFileCell.h"

@interface WSDetailFileDownLoadView : UIView <UITableViewDelegate,UITableViewDataSource>
-(instancetype)initWithFrame:(CGRect)frame withFiles:(NSArray *)Files addFileNames:(NSArray *)fileNames;

@end
