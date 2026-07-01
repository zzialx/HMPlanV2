//
//  WSScanListPanel.h
//  WinSFA
//
//  Created by winchannel on 15/11/16.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "WSScanListView.h"
#import "WSHTextField.h"

@interface WSScanListPanel : WSSingleTitlePanel<WSScanListViewDelegate,UITextFieldDelegate,WSHTextFieldDelegate>

@property (nonatomic, strong)WSHTextField  *textField;
@property (nonatomic, strong) WSScanListView *scanListView;
@property (nonatomic, strong) UIButton *confirButton;
@property (nonatomic, strong) UIButton *i_button;
@property (nonatomic, strong) NSMutableDictionary *addPhotoDict;
@property (nonatomic, strong) NSMutableDictionary *imeiImageIndexDict;

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *displayString;
@property (nonatomic, assign) BOOL isNotChangePanelHeight;

- (NSString *)getAcvtQstId;

// 表格内部控件调用，调查问卷调用还用之前的init方法
-(id)initWithFrame:(CGRect)frame andParam:(WSFuncsBean_Param *)aParam;

@end
