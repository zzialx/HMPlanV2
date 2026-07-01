//
//  NewStarContactWithInviteCell.h
//  NewSolution
//
//  Created by 李振杰 on 14-8-10.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//

#import "WSContactCell.h"
#import "WSWidget.h"

@class WSOpenCloseBtn;


@interface WSContactWithInviteCell : WSContactCell<WSWidgetDelegate>{
    
    
     WSOpenCloseBtn *invitebutton;
    
    
    
}


@end
