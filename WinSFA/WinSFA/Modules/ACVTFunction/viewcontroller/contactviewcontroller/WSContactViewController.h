//
//  WSContactViewController.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"


@class WSContactView;

@class WSContactDataSource;

@class ContactSearcher;


@interface WSContactViewController : WCBaseViewController{
    
    WSContactView  *contactview;
    
    WSContactDataSource  *datasource;
    
    ContactSearcher   *contactsearcher;
    
}

@property (nonatomic,retain)  WSContactView    *contactview;

@property (nonatomic,retain)  WSContactDataSource   *datasource;

@property (nonatomic,retain) ContactSearcher   *contactsearcher;


@end
