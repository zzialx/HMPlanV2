//
//  OTCSubempLISTViewController.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-7-2.
//
//

#import <Foundation/Foundation.h>
#import "WSSubempLISTViewController.h"

/* Zheng Jiepeng 2013/07/02 (创建)
 *  辉瑞零售（OTC）项目
 *  继承: SubempLISTViewController
 *  功能: 主管随访 中的 下级人员列表
 *  与原来的 下级人员列表 比较:
 *  0.下级人员 数据节点改为后台配置(原先为固定subempstore);
 *  1.添加搜索功能;
 *  2.点击人员后 发送实时请求.
 */
@interface OTCSubempLISTViewController : WSSubempLISTViewController 

@end
