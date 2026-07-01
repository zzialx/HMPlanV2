//
//  WSHelpItemDetalViewController.h
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSHelpDocument.h"
#import "WSHelpDocumentItemView.h"

@interface WSHelpItemDetalViewController : UIViewController <UIScrollViewDelegate>

- (id)initWithFuncs:(WSFuncsBean *)funcs helpDocument:(WSHelpDocument *)helpDocument itemView:(WSHelpDocumentItemView *)itemView;

@end
