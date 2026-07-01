//
//  WSTreeListPanel.h
//  WinSFA
//
//  Created by winchannel on 15/12/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "WSPersonnelListTreeView.h"


@interface WSTreeListPanel : WSSingleTitlePanel<WSPersonnelListTreeViewDelegate>



@property (nonatomic, strong) NSArray *dataArray;


#pragma mark - 多级菜单
@property (nonatomic, strong) NSMutableArray *multileveMenuArray;// 多级菜单的默认需要展示层级的所有数据
@property (nonatomic, strong) NSMutableArray *backShowLevelDataArray;// 多级菜单需要回显时候默认选中的各个层级数据
@property (nonatomic, assign) BOOL isUseMultilevelMenu;//是否使用多级菜单view SFA DV类型控件 玛氏

@end
