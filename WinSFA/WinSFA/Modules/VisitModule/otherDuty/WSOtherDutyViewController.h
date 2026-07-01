//
//  OtherDutyViewController.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-9-8.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "SuperWorkSpaceViewController.h"
#import "WSPhotoBrowseView.h"
#import "WSImagePickerController.h"

#define NOTIFY_SELECTPHOTO  @ "selectPhoto"
#define NOTIFY_REMOVEPHOTO  @ "removePhoto"


@interface WSOtherDutyViewController : SuperWorkSpaceViewController <UITextFieldDelegate, UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WSHTextFieldDelegate,UITextViewDelegate>
{
    NSString    *startTime;
    NSString    *endTime;
    
    NSMutableArray  *titles;
    NSMutableArray  *datas;
    NSMutableArray  *colWidth;
    NSMutableArray  *dataIDs;
    NSMutableString *memoData;
    UIDatePicker    *endDatepicker;
    NSDate          *beginDate;
    NSDate          *endedDate;
    
    
    UITextView *memo;
    
    
}

@property (nonatomic, copy) NSString            *startTime;
@property (nonatomic, copy) NSString            *endTime;
@property (nonatomic, strong) NSMutableArray    *titles;
@property (nonatomic, strong) NSMutableArray    *datas;
@property (nonatomic, strong) NSMutableArray    *colWidth;
@property (nonatomic, strong) NSMutableArray    *dataIDs;
@property (nonatomic, strong) NSMutableString   *memoData;
@property (nonatomic, strong) NSDate            *beginDate;
@property (nonatomic, strong) NSDate            *endedDate;
@property (nonatomic, copy) NSString            *md5;
@property (nonatomic, strong) UIScrollView      *contentScrollView;

@property (nonatomic, strong) WSPhotoBrowseView         *photoBrowseView;

@property (nonatomic, assign) float         y_point;


@property (nonatomic, assign) BOOL isValueChange;


- (id)initWithFuncs:(WSFuncsBean *)funcs;

- (void)checkRecordAlert;
- (NSString *)getTableColValueByProId:(NSString *)prodId col:(NSString *)parmCol;
- (void)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text  col:(NSString *)parmCol;
@end
