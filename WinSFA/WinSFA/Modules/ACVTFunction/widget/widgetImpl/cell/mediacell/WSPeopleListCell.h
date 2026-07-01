//
//  WSPeopleListCell.h
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTableViewCell.h"

@class WSPeopleContentView;


@interface WSPeopleListCell : WSTableViewCell{

    WSPeopleContentView  *people_content_view;
}

@property (nonatomic,strong) WSPeopleContentView  *people_content_view;


@end
