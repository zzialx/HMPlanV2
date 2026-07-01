//
//  WSSelectPeoplePanel.h
//  WinSFA
//
//  Created by zhangke on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"

@interface WSSelectInformationPanel : WSSingleTitlePanel

@property (nonatomic,strong) WSStoreBean* currentStore;
@property (nonatomic, strong) NSArray *params;

-(void)refresh;

-(NSString *)getValueForParam:(NSString*)paramString;

-(void)pushIntoWebview:(NSString*)paramsString;



@end
