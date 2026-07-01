//
//  OtherDutyViewController.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-9-8.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WSOtherDutyViewController.h"
#import "WSAppData.h"
#import "WinSFA.h"
#import "DataGridComponent.h"
#import "WSDictBean.h"
#import "WSRequestHelper.h"
#import "WSCurrentTime.h"
#import "WSFuncsBean_Param.h"
#import "WSFuncsBean_opt.h"
//#import "ConfigFileController.h"
#import "UIDevice+Addtional.h"
#import "WSOffLineUploadTable.h"
#import "WSJSONBuilder.h"
#import "WSMultipleChoiceLabel.h"
#import "WSFdtTable.h"

#import "MBProgressHUD.h"

#import "WSOfflineDataManager.h"
#import "WSImagePathTable.h"
#import "WSCustomTimeTable.h"
#import "WSDutyBeanArray.h"
#import "WidgetConstant.h"
#import "WSOthersAttendanceArray.h"
#import "WSOthersAttendanceBean.h"

#import "WSOfflineDataDBService.h"
#import "WSDateSelectView.h"
#import "WSBaseDictsDBService.h"
#import "WSLuaScriptContext.h"
#import "WSLuaScriptEnter.h"
#import "WSCheckBox.h"
#import "WSLuaExecutorManager.h"
#import "I_Lua_Executor.h"
#import "I_Lua_Target_Operator.h"

#define DATEPICKER_TAG      3
#define BUTTON_TAG_START    1
#define BUTTON_TAG_END      2
#define BUTTON_TAG_UPLOAD   4
#define kCheckboxButtonBase 350
#define OTHERDUTY         @"otherDuty_upload"

#define kDateViewHeight 67
#define kLineViewTopPadding 10

#define kOtherDutyDayRange  @"otherDutyDayRange"
#define kLeftVieWidth 200.0f

#define kBeginDateMustEqual              NSLocalizedString(@"start_date_tip_equal", nil)
#define kBeginDateMustLaterThanOrEqual   NSLocalizedString(@"start_date_tip", nil)
#define kBeginDateMustLessThanOrEqual   NSLocalizedString(@"start_date_tip_less_or_equal", nil)
#define kEndDateMustEqual                NSLocalizedString(@"end_date_tip_equal", nil);
#define kEndDateMustLessThanOrEqual      NSLocalizedString(@"end_date_tip", nil);



@interface WSOtherDutyViewController ()<I_Lua_Target_Operator>
@property (nonatomic, strong)NSArray* otherDutyArray;
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
//- (void)initView;
- (void)showDatePicker:(id)sender;
- (void)checkBoxPressed: (id)sender;
- (void)upload;
- (void)uploadFinished:(id)sender;
- (void)showAlert:(NSString *)message;
@end

@implementation WSOtherDutyViewController

@synthesize startTime;
@synthesize endTime;
@synthesize titles, datas, dataIDs, colWidth;
@synthesize currentFuncs;
@synthesize memoData;
@synthesize beginDate; 
@synthesize endedDate;

#pragma mark - View lifecycle

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter standardDateFormatter];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    return _dateFormatter;
}

-(void)initData
{
    
    if(self.currentFuncs.filter == nil)
    {
        return;
    }
    //首列title
    NSInteger paramCount = [self.currentFuncs.paramArray count];
    NSString* item =  NSLocalizedString(@"table_dict_title_project",nil);
    if ([self.currentFuncs.opt.name isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.name;
    } else if ([self.currentFuncs.opt.title isKindOfClass:[NSString class]]) {
        item = self.currentFuncs.opt.title;
    }
    [self.titles addObject:item];

    
    CGFloat detailSizeWidth = DETAILSIZEWIDTH;
    
    //NSString *itemWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"100" : @"70";
    NSString *itemWidth = ((self.currentFuncs.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFuncs.fCharNum * (int)detailSizeWidth] : [NSString stringWithFormat:@"%d", self.currentFuncs.wfcol]);
    if (itemWidth.integerValue <=0) {
        itemWidth = SHORT_COLUMN_WIDTH;
    }

    [self.colWidth addObject:itemWidth];
    
    // 其他列titles
    for(int i = 0 ; i < paramCount; i++)
    {
        WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i];
        [self.titles addObject:fb_Param.name];
    }
    
     NSString *fwol = nil;
    // 其他列widths
    for(int i = 0 ; i < paramCount; i++)
    {
        //以下是配置
        WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
        if (fb_Param.charNum.integerValue > 0)
        {
            [self.colWidth addObject:[NSString stringWithFormat:@"%f", fb_Param.charNum.integerValue * detailSizeWidth]];
        }
        else if(fb_Param.wcol != 0)
        {
            [self.colWidth addObject:[NSString stringWithFormat:@"%f", INTERFACE_IS_PAD ? (fb_Param.wcol * 2.5) : fb_Param.wcol*1.0]];
        }
        else
        {
            
            [self.colWidth addObject:[NSString stringNotNilWithValue: fwol]];
        }
    }
    
    if(![self isRemoveDay]){
        
        NSString* today =  NSLocalizedString(@"all_day",nil);
        [self.titles addObject:today];
        // 首列宽
        if (paramCount>1)
        {
            fwol = ((self.currentFuncs.charNum > 0) ? [NSString stringWithFormat:@"%f", self.currentFuncs.charNum *  detailSizeWidth] : [NSString stringWithFormat:@"%f", (float)self.currentFuncs.wfcol]);
            if (fwol.integerValue <=0) {
                fwol = ALLDAY_COLUMN_WIDTH;
            }
        }
        else
        {
            fwol = ((self.currentFuncs.charNum > 0) ? [NSString stringWithFormat:@"%f", self.currentFuncs.charNum * detailSizeWidth] : [NSString stringWithFormat:@"%f", (float)self.currentFuncs.wfcol ]);
            if (fwol.integerValue <=0) {
                fwol = DEFAULT_COLUM_WIDTH;
            }
        }
        [self.colWidth addObject:fwol];
    }
    //datas
    if (_otherDutyArray == nil) {
        _otherDutyArray = [[NSArray alloc] init];
    }
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    _otherDutyArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];

    //获取考勤回显数据
    NSArray *dicDatas = [self getDisDicDatas];

    NSArray *redisDatas = nil;
    
    // SFA-6498 跟安卓统一逻辑值为Yes的时候不显示回显
    if (![self isShowUpdated]) {
        // dosomething
     redisDatas = [self getOthersAttendanceData];
    }
    
    for (int i = 0; i < [_otherDutyArray count]; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] 
                                initWithCapacity:[self.titles count]];
        WSDictBean *dictcell = [_otherDutyArray objectAtIndex:i];
        [dataIDs addObject:dictcell.Id];
        //first column
        UILabel *firstcol = [[UILabel alloc] 
                             initWithFrame:CGRectMake(0,0,79,29)];
        firstcol.text = dictcell.name;
        firstcol.font = [UIFont systemFontOfSize:UI_Font];
        firstcol.textAlignment = NSTextAlignmentCenter;
        [row insertObject:firstcol atIndex:0];

        WSDictObject *object = nil;
        if (dicDatas != nil && [dicDatas count] > i)
        {
            object = [dicDatas objectAtIndex:i];
        }
        WSFuncsBean_Param *param = nil;
        for (int j = 0; j < [self.titles count]-1; j++)
        {
            if([self isRemoveDay]){
                param = [self.currentFuncs.paramArray objectAtIndex:j];
            }else{
                if (j == [self.titles count] - 2) {
                    ;
                }
                else
                {
                    param = [self.currentFuncs.paramArray objectAtIndex:j];
                }
            
            }

            
            
            if ([param.tpy
                 isEqualToString:COL_TYPNUM]){
                UITextField *textfield = [[UITextField alloc] 
                                          initWithFrame:CGRectMake(0, 0, 0, 0)];
                textfield.font = [UIFont systemFontOfSize:UI_Font];
                textfield.textAlignment = NSTextAlignmentLeft;
                textfield.delegate = self;
                textfield.keyboardType = UIKeyboardTypeNumberPad;

                if (object != nil) {
                    NSString *text = [object valueForKey:[NSString stringWithFormat:@"col%i",j+1]];
                    if (text) {
                        textfield.text = text;
                    }
                }
                
                [textfield addTarget:self
                              action:@selector(textWatcher:)
                    forControlEvents:UIControlEventEditingChanged];
                
                [row addObject:textfield];                
            }else if ([param.tpy 
                       isEqualToString:COL_TYPCHECKBOX]){
                WSCheckBox *check = [WSCheckBox buttonWithType:UIButtonTypeCustom];
                check.tag = j + kCheckboxButtonBase;
                check.frame = CGRectMake(0, 0, 0, 0);
                check.iRow = [dictcell.Id intValue];
                check.iColumn = j + 1;
                [check addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [check setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
                [check setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];

                if (object != nil) {
                    NSString *value = [object valueForKey:[NSString stringWithFormat:@"col%i",j+1]];
                    if (value != nil && [value isEqualToString:@"1"]) {
                        [check setSelected:YES];
                    }
                }
                
                if (param.redis && [param.redis isEqualToString:@"1"]) {
                    [check setSelected:[self checkValue:redisDatas andDictBean:dictcell andTitle:param.name]];
                }

                if (param.readonly) {
                    check.userInteractionEnabled = NO;
                    check.alpha = 0.65f;
                }else{
                    check.userInteractionEnabled = YES;
                    check.alpha = 1.0f;
                }
                
                [row addObject:check];
                //NSLog(@"row count is %d",[row count]);
            }
        }
        [self.datas addObject:row];
    }
}

- (void)generateCellDataWithRow:(NSInteger)row column:(NSInteger) column {
     // adicts  title是数据源  otherDutyArray回显数据
    // 数据可用数据映射到 models的集合中  models.markDic 日期，title  采集项
    // 通过model在collectionView绘制出来
}

-(void)setColunmViewWidth
{
    if(self.colWidth==nil)
    {
        NSMutableArray* colArray = [[NSMutableArray alloc]init];
        self.colWidth = colArray;
    }
    [self.colWidth removeAllObjects];
    NSUInteger paramCount = [self.currentFuncs.paramArray count];
    
    NSString *fwol = nil;
    if (paramCount>1)
    {
        fwol = ((self.currentFuncs.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFuncs.fCharNum * (int)DATAGRID_TITLE_FONTSIZE] : [NSString stringWithFormat:@"%d", self.currentFuncs.wfcol]);
        if (fwol.integerValue <=0) {
            fwol = SHORT_COLUMN_WIDTH;
        }
    }
    else
    {
        fwol = ((self.currentFuncs.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFuncs.fCharNum * (int)DATAGRID_TITLE_FONTSIZE] : [NSString stringWithFormat:@"%d", self.currentFuncs.wfcol]);
        if (fwol.integerValue <=0) {
            fwol = DEFAULT_COLUM_WIDTH;
        }
    }
}


/*
- (void)showMonthCalenderPanel {
    CGSize size = self.view.frame.size;
    if (_monthPanel == nil) {
        _monthPanel = [[WSMonthCalenderPanel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) funcs:self.currentFuncs];
        _monthPanel.monthPanelDelegate = self;
        [self.view addSubview:_monthPanel];
    } else {
        _monthPanel.hidden = NO;
    }
    
}
 */

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        titles = [[NSMutableArray alloc] init];
        datas = [[NSMutableArray alloc] init];
        colWidth = [[NSMutableArray alloc] init];
        dataIDs = [[NSMutableArray alloc] init]; 
        memoData = [[NSMutableString alloc]init];
        return self;
    }
    return nil;
}

-(void)loadView
{
    [super loadView];
    
//    UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
    self.view.backgroundColor = RGBCOLOR(247, 247, 247);
    
    [self initData];
    
    if (INTERFACE_IS_PAD) {
        CGRect frame = self.view.frame;
        frame.size.width = BROWSERVC_WIDTH - kLeftVieWidth;
        self.view.frame = frame;
    }
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.contentScrollView];
    self.contentScrollView.backgroundColor = RGBCOLOR(247, 247, 247);

    int kRowGap = 10;
    
    CGFloat kRowHeight = 50;

    int width = self.view.bounds.size.width - (INTERFACE_IS_PHONE ? 20.0f : 40.0f);
    int height = 30;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        height = 38;
        kRowGap = 10;
    }
    
    float y_position = 0;
    
    NSArray *fdtDataArray = [[WSFdtTable sharedTable] queryFdtWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:self.currentStore.srid];
    WSFdtObject *fdtObject = nil;
    if (fdtDataArray != nil && [fdtDataArray count] > 0) {
        fdtObject = [fdtDataArray objectAtIndex:0];
    }
    
    
    NSString *currentDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    if( self.currentFuncs.opt!=nil && [self.currentFuncs.opt.isAttendance isEqualToString:@"N"]){
        CGRect frame = CGRectMake((self.view.bounds.size.width - width)/2, y_position, width, height);
        UILabel* dateLabel=[[UILabel alloc] initWithFrame:frame];
        dateLabel.textAlignment=NSTextAlignmentCenter;
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSString *CurrentTimeString = NSLocalizedString(@"current_time",nil);
        dateLabel.text=[CurrentTimeString stringByAppendingFormat:@" %@",currentDate];
        dateLabel.textColor = kBLACK_COLOR_value;
        [self.contentScrollView addSubview:dateLabel];
        
        y_position += height + kRowGap;
        
    }else{
        
        if(![self isRemoveDay]){
            
            NSDate *date = [WSCurrentTime getCurrentServerDate];

            //begin
            NSDate *l_beginDate = date;
            if (fdtObject != nil && fdtObject.memo9 != nil && [fdtObject.memo9 length] > 0) {
                l_beginDate = [self.dateFormatter dateFromString:fdtObject.memo9];
            }
            
            WSDateSelectView *beginDateView = [[WSDateSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width/2, kDateViewHeight) title:NSLocalizedString(@"attendance_begin",nil) date:l_beginDate];
            //beginDateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            beginDateView.tag = BUTTON_TAG_START;
            UITapGestureRecognizer *tapBegin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker:)];
            [beginDateView addGestureRecognizer:tapBegin];
            
            
            //end
            NSDate *l_endDate = date;
            if (fdtObject != nil && fdtObject.memo10 != nil && [fdtObject.memo10 length] > 0) {
                l_endDate = [self.dateFormatter dateFromString:fdtObject.memo10];
            }
            
            WSDateSelectView *endDateView = [[WSDateSelectView alloc] initWithFrame:CGRectMake(self.view.width/2, 0, self.view.width/2, kDateViewHeight) title:NSLocalizedString(@"attendance_end",nil) date:l_endDate];
            //endDateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            endDateView.tag = BUTTON_TAG_END;
            UITapGestureRecognizer *tapEnd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker:)];
            [endDateView addGestureRecognizer:tapEnd];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.view.width / 2, kLineViewTopPadding, 1, kDateViewHeight - kLineViewTopPadding * 2)];
            line.backgroundColor = MAIN_SEPERATE_LINE_COLOR;
            
            [self.contentScrollView addSubview:beginDateView];
            [self.contentScrollView addSubview:endDateView];
            [self.contentScrollView addSubview:line];
            
            y_position += kDateViewHeight;
        }

    }
    
    
    DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc] 
                                            init];
    comData.titles = self.titles;
    comData.data = self.datas;
    comData.columnWidth = self.colWidth;
    comData.rowHeight = kRowHeight;
    
    NSInteger maxRow = self.currentFuncs.maxRow;
    if(maxRow > comData.data.count + 1 || maxRow == 0){
        maxRow = comData.data.count + 1;
    }
    
    CGFloat myheight = kRowHeight * maxRow + 10;
    
    DataGridComponent *compView = [[DataGridComponent alloc] initWithFrame: CGRectMake(0, y_position, CGRectGetWidth(self.view.bounds), myheight) data:comData];
    compView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentScrollView addSubview:compView];
    
    y_position += myheight + kRowGap;

    
    if (![self.currentFuncs.opt.isMemo isEqualToString:REQUIRED_NEGATIVE]) {
        int width = self.view.bounds.size.width - (INTERFACE_IS_PHONE ? 20.0f : 40.0f);
        
        int height = 50;

        CGRect  rect ;
        
        if (INTERFACE_IS_PAD) {
            
            rect = CGRectMake((self.view.bounds.size.width - width)/2,  y_position, width, height);
            
        }else{
            CGFloat yPoint = IS_IPHONE5 ? y_position : (y_position-height*2)-3.0;
            
            if (IS_IPHONE4S) {
                
                yPoint = y_position;
            }
            
            rect= CGRectMake((self.view.bounds.size.width - width)/2, yPoint, width, height);
        }
        
        if (self.view.height - rect.origin.y - 15 >= 100) {
            rect.size.height = 100;
        }
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(-1, rect.origin.y, self.view.width + 2, rect.size.height + 10)];
        bgView.layer.borderWidth = MAIN_CELL_SEPERATOR_HEIGHT;
        bgView.layer.borderColor = MAIN_SEPERATE_LINE_COLOR.CGColor;
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentScrollView addSubview:bgView];
        
        memo = [[UITextView alloc]initWithFrame:CGRectMake(rect.origin.x, 5, rect.size.width, rect.size.height)];
        memo.font = [UIFont systemFontOfSize:UI_Font];
        memo.layer.borderColor = [UIColor clearColor].CGColor;
        
        memo.backgroundColor = [UIColor whiteColor];
        memo.returnKeyType = UIReturnKeyDone;
        memo.delegate = self;
        memo.keyboardType = UIKeyboardTypeDefault;
        NSString *MemoString = NSLocalizedString(@"w_task_remark",nil);
        //阴影字
        memo.text = MemoString;
        memo.textColor = [UIColor lightGrayColor];
        
        //回显值
        if (fdtObject.memo8.length >0 && ![fdtObject.memo8 isEqualToString:@"null"]) {
            [memo setText:fdtObject.memo8];
        }
        memo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [bgView addSubview:memo];
        
        y_position += height + 5;
    }

    self.y_point = y_position;
    
    
    //add by wangdongyan 03-27 for 给开始时间与结束时间赋直
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter  setDateFormat:@"yyyy-MM-dd"];
    self.beginDate=[formatter dateFromString:currentDate];
    self.endedDate=[formatter dateFromString:currentDate];
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y_position);
    [self addOptView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *upload =[[UIBarButtonItem alloc]initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(checkRecordAlert)];
    
    NSArray *toolBarArr=[NSArray arrayWithObjects:upload, nil];
    if (self.ownParentViewController != nil) {
        self.ownParentViewController.navigationItem.rightBarButtonItems = toolBarArr;
    } else {
        self.navigationItem.rightBarButtonItems = toolBarArr;
    }
    


}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.ownParentViewController != nil) {
        self.ownParentViewController.navigationItem.rightBarButtonItems = nil;
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addOptView
{
    WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
    if (fb_opt.isPic) {
        if(![fb_opt.isPic isEqualToString:REQUIRED_N])
        {
            [self addPicture];
        }
    }
}

-(void)addPicture
{
    //拍照放在页面里面
    if (self.photoBrowseView == nil) {
        NSArray *imagePathArray = [self getImagePathFromDataBase];
        WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
        
        BOOL isSupperLocalPic = (fb_opt.isSupperLocalPhoto == 1);
        if (isSupperLocalPic) {
            if (self.currentStore && self.currentStore.Id)
            {
                //玛氏日本修改，原来的补录功能查询只需storeID，后来不知为何加入了md5,影响玛氏的功能，因为上传页面存的md5和acvt页面的md5肯定不一样，所以不可能查询出门店是否补录，故而先去掉md5。
                NSString *enterDateStr = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:self.currentStore.Id withVisitId:nil];
                if (!enterDateStr) {
                    isSupperLocalPic = NO;
                }
            }else {
                isSupperLocalPic = NO;
            }
        }
        
//        WSPhotoBrowseView *photoView = [[WSPhotoBrowseView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, kPhotoBrowseViewHeight)
//                                                               withImageIDArray:imagePathArray
//                                                             withSupperLocalPic:isSupperLocalPic
//                                                                withMaxPhotoNum:fb_opt.maxPhoto];
                WSPhotoBrowseView *photoView = [[WSPhotoBrowseView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, PHOTO_PANEL_HEIGHT)
                                                                                    funs:self.currentFuncs 
                                                                       withImageIDArray:imagePathArray
                                                                     withSupperLocalPic:isSupperLocalPic
                                                                      withSupperHttpPic:NO
                                                                        withMaxPhotoNum:fb_opt.maxPhoto
                                                                               delegate:nil  
                                                                            align:nil
                                                                        withDisPlayMode:nil];

        photoView.viewController = self.ownParentViewController ? self.ownParentViewController : self;
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        photoView.currentStore = self.currentStore;
        self.photoBrowseView = photoView;
        
        [self.contentScrollView addSubview:photoView];
        self.y_point += PHOTO_PANEL_HEIGHT + 15;
        
        self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    }
}


- (NSArray *)getImagePathFromDataBase
{
    NSMutableArray *imagePathArray = nil;
    
    NSArray *imageObjectArray = [[WSFdtTable sharedTable] queryFdtImagePathWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:self.currentStore.srid];
    if (imageObjectArray && [imageObjectArray count] > 0) {
        imagePathArray = [[NSMutableArray alloc] init];
        for (WSImagePathObject *object in imageObjectArray) {
            NSString *imageID = object.img_path;
            if (imageID && [imageID length] > 0) {
                [imagePathArray addObject:imageID];
            }
        }
    }
    
    return imagePathArray;
}


- (void)showDatePicker:(id)sender{

    // SFA-8422 停止文本输入的响应
    [self.view endEditing:YES];
    
    UIView *view;
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        view = [(UIGestureRecognizer*)sender view];
    }
    
    NSDate *date;
    if ((view).tag==BUTTON_TAG_START) {
        date = self.beginDate;
    } else if (view.tag==BUTTON_TAG_END) {
        date = self.endedDate;
    }
    
    WSPickerViewType pickerViewType = WSPickerViewTypeDate;
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType];
    
    [pickerView setDate:date animated:YES];
    
    if (view.tag==BUTTON_TAG_END) {
        [pickerView setMinimumDate:self.beginDate];
    }
    NSInteger tag = view.tag;
    pickerView.tag = tag;
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        date = [self formatNSDateWithOutSeconds:date];
        
        [weakSelf setDateContent:date withTag:tag];
    }];
    
}

#pragma mark DatePickerSheetDelegate
- (void)setDateContent:(NSDate *)date withTag:(NSInteger)tag{
    //获取系统配置的限制时间.
    NSDate* minData;
    NSDate* maxData;
    
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* ranges = [service queryDictsForAcvtGridWithFilter:kOtherDutyDayRange];
    
    if([ranges count]> 0)
    {
        WSDictBean* dict = [ranges objectAtIndex:0];
        NSString* rangeString = dict.dtyp;
        NSDictionary* rangedic = [rangeString objectFromJSONString];
        NSString* min = [rangedic objectForKey:@"min"];
        NSString* max = [rangedic objectForKey:@"max"];
        
        NSTimeInterval minint = [min intValue]*24*60*60;
        
        // MMSH-4084 同步安卓逻辑此处最大日期数需默认减去1（算今天为验证最大日期的第一天）
        int maxIntValue = [max intValue];
        if (maxIntValue > 0) {
            maxIntValue = maxIntValue - 1;
        }
        NSTimeInterval maxint = maxIntValue*24*60*60;
        
        minData = [NSDate dateWithTimeIntervalSinceNow:minint];
        maxData = [NSDate dateWithTimeIntervalSinceNow:maxint];
    }
    

    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    WSDateSelectView *dateView = (WSDateSelectView *)[self.view viewWithTag:tag];
    WSDateSelectView *endDateView = (WSDateSelectView*)[self.view viewWithTag:BUTTON_TAG_END];
    
    
    switch (dateView.tag) {
        case BUTTON_TAG_START:
           
            minData = [self formatNSDateWithOutSeconds:minData];
            maxData = [self formatNSDateWithOutSeconds:maxData];
            
            if ([date compare:minData] != NSOrderedAscending && [date compare:maxData] != NSOrderedDescending) {
                self.beginDate = date;
                
                if ([self.beginDate compare:self.endedDate] == NSOrderedDescending) {
                    self.endedDate = date;
                    [endDateView setDate:self.endedDate];
                }
                
            }
            if([date compare:minData] == NSOrderedAscending){
                
                NSString *tipStr;
                if ([minData compare:maxData] == NSOrderedSame) {
                    tipStr = kBeginDateMustEqual;
                }else{
                    tipStr = kBeginDateMustLaterThanOrEqual;
                }
                
                NSString *minDataStr = [formatter stringFromDate:minData];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:minDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            if([date compare:maxData] == NSOrderedDescending){
                
                NSString *tipStr;
                if ([minData compare:maxData] == NSOrderedSame) {
                    tipStr = kBeginDateMustEqual;
                }else{
                    tipStr = kBeginDateMustLessThanOrEqual;
                }
                
                NSString *maxDataStr = [formatter stringFromDate:maxData];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:maxDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            
            //设置开始日期
            [dateView setDate:self.beginDate];
            
            break;
            
        case BUTTON_TAG_END:
            
            minData = [self formatNSDateWithOutSeconds:minData];
            maxData = [self formatNSDateWithOutSeconds:maxData];
            self.beginDate = [self formatNSDateWithOutSeconds:self.beginDate];
            
            if (([date compare:maxData] == NSOrderedAscending || [date compare:maxData] == NSOrderedSame) && ([date compare:self.beginDate] != NSOrderedAscending)) {
                self.endedDate = date;
                [dateView setDate:self.endedDate];
            }
            
            if ([date compare:maxData] == NSOrderedDescending ) {
                NSString *tipStr;
                if ([minData compare:maxData] == NSOrderedSame) {
                    tipStr = kEndDateMustEqual;
                }else{
                    tipStr = kEndDateMustLessThanOrEqual;
                }
                NSString *maxDataStr = [formatter stringFromDate:maxData];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:maxDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            
            
            if ([date compare:minData] == NSOrderedAscending) {
                NSString *tipStr;
                if ([minData compare:maxData] == NSOrderedSame) {
                    tipStr = kEndDateMustEqual;
                }else{
                    tipStr = kEndDateMustLessThanOrEqual;
                }
                NSString *maxDataStr = [formatter stringFromDate:minData];
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:maxDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
        default:
            break;
    }
}



- (NSDate *)formatNSDateWithOutSeconds:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *oneDayStr = [dateFormatter stringFromDate:date];
    
    return [dateFormatter dateFromString:oneDayStr];
}

- (void)checkBoxPressed: (id)sender
{
    if (![sender isKindOfClass:[UIButton class]]) {  return; }
    WSCheckBox *btnSender = (WSCheckBox *)sender;
    [btnSender setSelected:!btnSender.isSelected];
    //是否点击全天
    BOOL isClickedWholeDay = (btnSender.tag - kCheckboxButtonBase) == [self.currentFuncs.paramArray count];
    
    if (isClickedWholeDay)
    {

            // 点击的是”全天“按钮d 情况
            for (NSArray *items in self.datas)
            {
                BOOL isClickedRow = [items containsObject:sender];
                BOOL shouldWholeDay = NO;
                // item为每一个UI元素
                for (int i = 0;i < items.count;i++)
                {
                    
                    id item = [items objectAtIndex:i];
                    if (![item isKindOfClass:[UIButton class]]) {   continue;   }
                    UIButton *btn = (UIButton *)item;
                    NSInteger j = btn.tag - kCheckboxButtonBase;
                    
                    if (isClickedRow)
                    {
                       if (self.currentFuncs.value.length ==  0) { // 没配脚本的话，走原来的逻辑
                           
                        [btn setSelected:btnSender.isSelected];
                           
                       }else{
                           
                        [self executeLuaScripWithiRow:[NSString stringWithFormat:@"%d",btnSender.iRow] andScrip:self.currentFuncs.value];
                       }
                        
                    }
                    else
                    {
                        if (item != [items lastObject])
                        {
                            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
                            if (param.isMutex)
                            {
                                if (btnSender.isSelected) {
                                    [btn setSelected:NO];
                                }
                            }
                            if (![btn isSelected]) {
                                shouldWholeDay = NO;
                            }else{
                                [btn setSelected:NO];
                            }
                        }
                        else
                        {
                            [btn setSelected:shouldWholeDay];
                        }
                    }
                }

            }

    }
    else
    {
        if ([self isRemoveDay]) {
            
            for (NSArray *items in self.datas)
            {
                BOOL isClickedRow = [items containsObject:sender];
                // item为每一个UI元素
                for (NSInteger i = 0;i < items.count;i++)
                {
                    
                    id item = [items objectAtIndex:i];
                    if (![item isKindOfClass:[UIButton class]]) {   continue;   }
                    UIButton *btn = (UIButton *)item;
                    NSInteger j = btn.tag - kCheckboxButtonBase;
                    
                    if (!isClickedRow)
                    {
                        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
                        if (param.isMutex)
                        {
                            if (btnSender.isSelected && btnSender.tag == btn.tag) {
                                [btn setSelected:NO];
                            }
                        }
                    }
                }
            }
        }else{
            // 点击的是非全天按钮
            for (NSArray *items in self.datas)
            {
                BOOL isClickedRow = [items containsObject:sender];
                BOOL shouldWholeDay = NO;
                // item为每一个UI元素
                for (NSInteger i = 0;i < items.count;i++)
                {
                    
                    id item = [items objectAtIndex:i];
                    if (![item isKindOfClass:[UIButton class]]) {   continue;   }
                    UIButton *btn = (UIButton *)item;
                    NSInteger j = btn.tag - kCheckboxButtonBase;
                    
                    if (isClickedRow)
                    {
                        if (item != [items lastObject])
                        {
                            if (![btn isSelected]) {
                                shouldWholeDay = NO;
                            }
                        }
                        else
                        {
                            [btn setSelected:shouldWholeDay];
                        }
                    }
                    else
                    {
                        if (item != [items lastObject])
                        {
                            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
                            if (param.isMutex)
                            {
                                if (btnSender.isSelected && btnSender.tag == btn.tag) {
                                    [btn setSelected:NO];
                                }
                            }
                            if (![btn isSelected]) {
                                shouldWholeDay = NO;
                            }
                        }
                        else
                        {
                            [btn setSelected:shouldWholeDay];
                        }
                    }
                }
              
                if (isClickedRow) {
                    WSFuncsBean_Param *colParam = [self.currentFuncs.paramArray objectAtIndex:btnSender.tag - kCheckboxButtonBase ];
                    if (colParam.value.length > 0 && [colParam.name isEqualToString:[self.titles objectAtIndex:btnSender.iColumn]]) { // 如果有脚本走脚本，没有就走以前的逻辑
                        [self executeLuaScripWithiRow:[NSString stringWithFormat:@"%d",btnSender.iRow] andScrip:colParam.value];
                        
                    }
                }

                
            }
        
        }
        


    }
}

/*
 上传时体醒已选择的考勤
 */
- (void)checkRecordAlert {
    
    // SFA-8926 校验之前先结束textview的第一响应，避免出现键盘遮住上传提示的现象
    [self.view endEditing:YES];
    
    BOOL flag = NO;
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter  setDateFormat:@"yyyy-MM-dd"];
    NSString *tempBeginTime =[formatter stringFromDate:self.beginDate];
    NSString *tempEndTime = [formatter stringFromDate:self.endedDate];
    NSString *alterContrent = @"";
    
    // SFA-8025 按行查改为按列查，从而避免下午在上午之前的情况
    NSArray *firstArray = [self.datas firstObject];

    if (firstArray.count > 0 && [firstArray isKindOfClass:[NSArray class]]) {
        for (NSInteger i = 0; i < [firstArray count] - 1; i++) {
             for (NSInteger j = 0; j < [self.datas count]; j++) {
                 
                 NSArray *subarray = [self.datas objectAtIndex:j];
                 if ([subarray isKindOfClass:[NSArray class]]) {
                     id obj = [subarray objectAtIndex:i];
                     
                     if ([obj isKindOfClass:[UIButton class]]) {
                         UIButton *button = (UIButton *)obj;
                         
                         if (button.isSelected) {
                             flag = YES;
                             /*
                              dictBean.name（病假，事假，婚假等）
                              */
                             WSDictBean *dictBean = [self.otherDutyArray objectAtIndex:j];
                             /*
                              subarray中第一个第四个都不是要取的数据
                              */
                             if (i > 0 &&  i < [subarray count] - 1) {
                                 WSFuncsBean_Param *parm = [self.currentFuncs.paramArray objectAtIndex:i-1];
                                 if (dictBean.name) {
                                     if ([alterContrent length] > 0) {
                                         alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"\n%@",dictBean.name]];
                                     } else {
                                         alterContrent = [alterContrent stringByAppendingString:dictBean.name];
                                     }
                                 }
                                 if (tempBeginTime && tempEndTime) {
                                     alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"  %@ - %@  ",tempBeginTime,tempEndTime]];
                                 }
                                 if (parm.name) {
                                     if (tempBeginTime) {
                                         alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"%@",parm.name]];
                                     } else {
                                         alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"  %@",parm.name]];
                                     }
                                     
                                 }
                             }
                         }
                     }
                 }

            }

                 
        }
    }

    // 以下为之前按行查的代码逻辑，暂时先注释掉
//    for (NSInteger i = 0; i < [self.datas count]; i++) {
//        NSArray *subarray = [self.datas objectAtIndex:i];
//        
//        if ([subarray isKindOfClass:[NSArray class]]) {
//            for (NSInteger j = 0; j < [subarray count] - 1; j++) {
//                id obj = [subarray objectAtIndex:j];
//                
//                if ([obj isKindOfClass:[UIButton class]]) {
//                    UIButton *button = (UIButton *)obj;
//            
//                    if (button.isSelected) {
//                        flag = YES;
//                        /*
//                         dictBean.name（病假，事假，婚假等）
//                         */
//                        WSDictBean *dictBean = [self.otherDutyArray objectAtIndex:i];
//                        /*
//                         subarray中第一个第四个都不是要取的数据
//                         */
//                        if (j > 0 &&  j< [subarray count] - 1) {
//                            WSFuncsBean_Param *parm = [self.currentFuncs.paramArray objectAtIndex:j-1];
//                            if (dictBean.name) {
//                                if ([alterContrent length] > 0) {
//                                    alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"\n%@",dictBean.name]];
//                                } else {
//                                    alterContrent = [alterContrent stringByAppendingString:dictBean.name];
//                                }
//                            }
//                            if (tempBeginTime && tempEndTime) {
//                                alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"  %@ - %@  ",tempBeginTime,tempEndTime]];
//                            }
//                            if (parm.name) {
//                                if (tempBeginTime) {
//                                    alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"%@",parm.name]];
//                                } else {
//                                    alterContrent = [alterContrent stringByAppendingString:[NSString stringWithFormat:@"  %@",parm.name]];
//                                }
//                                
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
    if([self.memoData length]>0&&flag==NO)
    {
        NSString *attendanceString = NSLocalizedString(@"w_attendance",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:attendanceString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    if(!flag)
    {
        NSString *AllDataString = NSLocalizedString(@"attendance_no_data",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AllDataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    //日期限制--重复代码太多,需要重构
    //获取系统配置的限制时间.
    NSDate* minData;
    NSDate* maxData;
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* ranges = [service queryDictsForAcvtGridWithFilter:kOtherDutyDayRange];
    
    if([ranges count]> 0)
    {
        WSDictBean* dict = [ranges objectAtIndex:0];
        NSString* rangeString = dict.dtyp;
        NSDictionary* rangedic = [rangeString objectFromJSONString];
        NSString* min = [rangedic objectForKey:@"min"];
        NSString* max = [rangedic objectForKey:@"max"];
        
        NSTimeInterval minint = [min intValue]*24*60*60;
        NSTimeInterval maxint = [max intValue]*24*60*60;
        
        minData = [NSDate dateWithTimeIntervalSinceNow:minint];
        maxData = [NSDate dateWithTimeIntervalSinceNow:maxint];
    }
    minData = [self formatNSDateWithOutSeconds:minData];
    maxData = [self formatNSDateWithOutSeconds:maxData];
    NSDate *beginTime = [self formatNSDateWithOutSeconds:self.beginDate];
    NSDate *closeTime = [self formatNSDateWithOutSeconds:self.endedDate];
    
    if([beginTime compare:minData] == NSOrderedAscending){
        
        NSString *tipStr;
        if ([minData compare:maxData] == NSOrderedSame) {
            tipStr = kBeginDateMustEqual;
        }else{
            tipStr = kBeginDateMustLaterThanOrEqual;
        }
        
        NSString *minDataStr = [formatter stringFromDate:minData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:minDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    if([beginTime compare:maxData] == NSOrderedDescending){
        
        NSString *tipStr;
        if ([minData compare:maxData] == NSOrderedSame) {
            tipStr = kBeginDateMustEqual;
        }else{
            tipStr = kBeginDateMustLessThanOrEqual;
        }
        
        NSString *maxDataStr = [formatter stringFromDate:maxData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:maxDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if ([closeTime compare:maxData] == NSOrderedDescending) {
        NSString *tipStr;
        if ([minData compare:maxData] == NSOrderedSame) {
            tipStr = kEndDateMustEqual;
        }else{
            tipStr = kEndDateMustLessThanOrEqual;
        }
        NSString *maxDataStr = [formatter stringFromDate:maxData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(tipStr, nil) tips:maxDataStr  tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    
    /*
     如有已有数据填写则提示已填写的数据是否上传
     */
    NSString *title = NSLocalizedString(@"confirm_attendace_upload", nil);
    NSString *cancelTitle = NSLocalizedString(@"cancel_label", nil);
    NSString *destructiveTitle = NSLocalizedString(@"confirm", nil);
    NSString *message = alterContrent;
    
    if ([self isRemoveDay]) {
        if(self.currentFuncs.name && [self.currentFuncs.name length] > 0)
            title = [NSString stringWithFormat:@"确定上传%@?",self.currentFuncs.name];
            message = @"";
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
    [alert setCancelButtonWithTitle:cancelTitle block:nil];
    [alert addButtonWithTitle:destructiveTitle block:^{
        [self upload];
    }];
    
    [alert show];
    
}


-(BOOL)uploadVisitAction
{
    if (![self.currentFuncs.value isEqualToString:@"hideVisitedFlag"]) {
        
        LogInfo(@" %@,%@ uploadVisitAction ",self.currentVisitAction.title, self.currentFuncs.fc);
        
        if (self.currentVisitAction) {
            
            return [self manageActionStatus:self.currentVisitAction];
        }
        
    }
    
    return YES;
}


- (void)upload{
    
    [self uploadVisitAction];
    
    WSDateSelectView *start = (WSDateSelectView *)[self.view viewWithTag:BUTTON_TAG_START];
    self.startTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    if ([[start getDateString] length] > 0) {
        self.startTime = [start getDateString];
    }
    
    WSDateSelectView *end = (WSDateSelectView *)[self.view viewWithTag:BUTTON_TAG_END];
    
    self.endTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    if ([[end getDateString] length] > 1) {
        self.endTime = [end getDateString];
    }

    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    WSFuncsBean_Param *param = [self.currentFuncs.paramArray firstObject];
    NSString *dictType = param.col ? param.col : @"otherDutyTime";
    NSArray* otherDutyArray = [service queryDictsForAcvtGridWithFilter:dictType];
    
    if (!otherDutyArray || otherDutyArray.count == 0) {
        NSString *message = [NSString stringWithFormat:@"配置错误，表格列的col为%@，找不到对应类型的字典项！", dictType];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title",nil) message:message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm",nil) block:nil];
        [alert show];
        return;
    }
    
    if (!self.md5)
    {
        NSString* l_dateStr = [WSCurrentTime getDateTime];
        self.md5 = [Md5Manager getMd5ByEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]
                                     sotreId:self.currentStore.Id
                                     bizDate:l_dateStr
                                    funcCode:self.currentFuncs.fc
                                      acvtId:nil
                                        memo:nil];
    }
    
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:notifyID
                                               object:nil];
    
    
    NSMutableArray *dataArrayForUpload = [[NSMutableArray alloc] init];
    for (int i = 0;i<self.datas.count;i++) {
        NSArray *dataArray = [self.datas objectAtIndex:i];
        NSMutableArray *dataRow = [[NSMutableArray alloc] init];
        NSInteger maxCount = dataArray.count - 1;
        if ([self isRemoveDay]) {
            maxCount = dataArray.count;
        }
        for (int j = 0; j < maxCount; j++) {
            [dataRow addObject:[dataArray objectAtIndex:j]];
        }
        [dataArrayForUpload addObject:dataRow];
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    if([memo.text isEqualToString:NSLocalizedString(@"w_task_remark",nil)]){
        self.memoData = nil;
    }else
        self.memoData = (NSMutableString *)memo.text;


    
    
    //存入离线上传表
    NSString *postData = [WSJSONBuilder buildbuildAttendancebyFuncs:self.currentFuncs
                                                             cols:otherDutyArray
                                                            datas:dataArrayForUpload
                                                          dataIDs:self.dataIDs
                                                        dateBegin:self.startTime
                                                          dateEnd:self.endTime
                                                             memo:self.memoData
                                                              md5:self.md5];
    BOOL insertOtherDutyDataIsSucceed = [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID];
    
    if (!insertOtherDutyDataIsSucceed) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }

    //存入wch_fdt
    if (![self insertDictDataToDatabase]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    if (![self uploadPhotos]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    [[WSRequestHelper shareInstance] uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyID md5:self.md5 isUpload:YES];
}

- (void)uploadFinished:(id)sender{
    
    NSNotification *notification = (NSNotification *)sender;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[notification name]
                                                  object:nil];

    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
        
    if (error) {
        //NSLog(@"error ?");
    }else{
        NSDictionary *uploadState = [info objectFromJSONString];
        int isSuccess = [[uploadState objectForKey:@"result"] intValue];
        
        if (isSuccess) {
            
            NSString *tmpString = NSLocalizedString(@"upload_success",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            [self backAction];
        }else{
//            [self showAlert:[uploadState objectForKey:MESSAGE]];
        }
    }
    
   
 
  
}

- (void)showAlert:(NSString *)message{
    
//    NSString *UploadFailString = NSLocalizedString(@"fail_upload",nil);
    NSString *UploadFailString = NSLocalizedString(@"js_alert_title",nil);
    NSString *OkString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:UploadFailString message:message];
    [alert setCancelButtonWithTitle:OkString block:nil];
    [alert addButtonWithTitle:TryString block:^{
        [self upload];
    }];
    [alert show];
}

- (void)memoData:(id)sender
{
 
   [memoData setString:((UITextField*)sender).text];
}
//modity 坐标为120 （原来为220） 2012－03－28  by yanguoshuai
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    self.view.center = CGPointMake(self.view.center.x, self.view.center.y-210);
//}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [self animationsOnTextField:YES];
    //self.view.center = CGPointMake(self.view.center.x, self.view.center.y+210);
    if ([textView.text isEqualToString:NSLocalizedString(@"w_task_remark",nil)]) {
        textView.text = @"";
        textView.textColor =[UIColor blackColor];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [self animationsOnTextField:NO];
    [textView resignFirstResponder];
    if (textView.text.length <1) {
        textView.text = NSLocalizedString(@"w_task_remark",nil);
        textView.textColor = [UIColor lightGrayColor];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [self animationsOnTextField:NO];
        [textView resignFirstResponder];
        return YES;
    }
    return YES;
}
- (void)animationsOnTextField:(BOOL)up{
    //    MMSH-4058
    //    SFA玛氏中国MWC- 【IOS:考勤报备】在考勤报备填写了备注后，不能上滑看到开始和结束日期
    CGFloat navH =UI_NAVIGATION_BAR_HEIGHT + UI_STATUS_BAR_HEIGHT;
    
    int y[2] = {navH, -160 - 90};
    
    [UIView beginAnimations:@"showkeyboard" context:nil];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationDuration:0.3f];
    
    CGRect newFrame = self.view.frame;
    
    newFrame.origin.y = y[up];
    
    [self.view setFrame:newFrame];
    
    //[self.sysNameLogo setFrame:CGRectMake(0, y[up] + 20, self.view.bounds.size.height, k_LogoImageHeight)];
    
    [UIView commitAnimations];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
//    self.view.center = CGPointMake(self.view.center.x, self.view.center.y+210);
   //[self.memoData setString:textField.text];
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"])  
    { 
        return YES; 
    } 
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; 
    if (textField)  
    { 
        WSFuncsBean_opt *funcs=self.currentFuncs.opt;
        if ([toBeString length] > funcs.numMemo) { 
        
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"text_exceed_max_length", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

            
            return NO; 
        } 
    } 
    return YES; 
}


-(BOOL)insertDictDataToDatabase
{
    
    if(![self.currentFuncs.ds isEqualToString:@"dicts"]){
        LogError(@"self.currentFuncs.ds 不为dicts 插入不执行");
        return NO;
    }

    
    NSMutableArray *dictValues = [[NSMutableArray alloc]init];
    //产品数量
    for(int i = 0 ; i < [self.datas count];i++)
    {
        NSMutableArray* dictRow = [[NSMutableArray alloc]init];
        
        for (int m = 0; m < 14; m++)
        {
            [dictRow addObject:@"null"];
        }
        NSArray* row = (NSArray*)[self.datas objectAtIndex:i];
        //idx
        [dictRow replaceObjectAtIndex:0 withObject:self.md5];
        //dict_id
        NSString* dictId = [self.dataIDs objectAtIndex:i];
        [dictRow replaceObjectAtIndex:1 withObject:[NSString stringNotNilWithValue:dictId]];
        
        for(int j = 1 ; j < [row count] ;j++)
        {
            int colNum = j + 1;
            if([[row objectAtIndex:j] isKindOfClass:[UITextField class]])
            {
                UITextField* view = (UITextField*)[row objectAtIndex:j];
                //col
                if(view.text != nil)
                    
                    [dictRow replaceObjectAtIndex:colNum withObject:view.text];
                
            }else if([[row objectAtIndex:j] isKindOfClass:[UIButton class]])
            {
                UIButton* button = (UIButton*)[row objectAtIndex:j];
                if(button.isSelected)
                {
                    [dictRow replaceObjectAtIndex:colNum withObject:@"1"];
                }else{
                    [dictRow replaceObjectAtIndex:colNum withObject:@"0"];
                }
                
            }else if([[row objectAtIndex:j] isKindOfClass:[WSMultipleChoiceLabel class]])
            {
                WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel *)[row objectAtIndex:j];
                NSString *value = (label.iContent != nil) ? label.iContent : @"";
                [dictRow replaceObjectAtIndex:colNum withObject:value];
            }
        }
        
        [dictValues addObject:dictRow];
    }

    NSString *storeid = nil;
    if (self.currentStore != nil) {
        if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
            storeid = self.currentStore.Id;
        }else{
            storeid = @"";
        }
    }else{
        storeid = @"";
    }
    
    
     NSString *srid = (self.currentStore.srid && [self.currentStore.srid length] > 0 ) ? [self.currentStore.srid copy] : @"null";
    
    NSNumber* isPlan = (self.currentStore != nil && [self.currentStore isKindOfClass:[WSStoreBean class]]) ? [NSNumber numberWithBool:self.currentStore.plan] : [NSNumber numberWithBool:YES];
    
    
    NSString *memoSource = (self.memoData && self.memoData.length > 0) ?[self.memoData copy]:@"null";

    NSString *currentDate=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray* fdtValues = [NSArray arrayWithObjects:self.currentFuncs.fc,self.currentFuncs.fv,[isPlan stringValue],@"null",storeid,[WSAppData getObjectbyKey:APPDATA_EMPID],[WSAppData getObjectbyKey:APPDATA_BIZDATE],currentDate,@"0",self.md5,srid,@"null",@"null",@"null",@"null",@"null",@"null",@"null",@"null",memoSource,self.startTime,self.endTime,@"null", nil];
    
    
    return [[WSFdtTable sharedTable] insertWithFdtArray:fdtValues Dict:dictValues];
}



-(BOOL)uploadPhotos{
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSMutableArray *dicValueArray = [[NSMutableArray alloc] init];
    for (NSString *imageID in self.photoBrowseView.imageIDArray) {

        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        if (filePath)
        {
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
            
            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
    
            BOOL insertAcvtDataIsSucceed = [WSOfflineDataDBService insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
            
            if (!insertAcvtDataIsSucceed) {
                return insertAcvtDataIsSucceed;
            }
            NSArray* array=[NSArray arrayWithObjects:self.md5,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
            
            [dicValueArray addObject:array];
            
            [uploadMgr uploadImageWithFilePath:filePath
                                        params:params
                                           url:URL_IMAGEUPLOAD
                                    notifyName:notifyID
                                           md5:self.md5];
        }
    }
    
    if (dicValueArray && [dicValueArray count] > 0) {
        [[WSImagePathTable sharedTable] updateWithImageIDX:self.md5 withValuesArray:dicValueArray];
    }
    else
    {
        [[WSImagePathTable sharedTable] deleteWithImageIDX:self.md5];
    }
    return YES;
}


- (void)showDBErrorTipAndHidAllHud {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"页面数据插入数据库失败，请重新上传", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}

#pragma sanofi method
// 去掉 开始结束日期， 表格去掉全天
- (BOOL) isRemoveDay
{

    if(self.currentFuncs.opt
       && self.currentFuncs.opt.removeDay){
           return YES;
       }
    return NO;
}
//回显服务端数据。
- (BOOL) isShowUpdated
{
    if(self.currentFuncs.opt
       && self.currentFuncs.opt.isShowUpdated){
        return YES;
    }
    return NO;
}

- (NSArray *) getOthersAttendanceData
{
    WSOthersAttendanceArray *othersAttendanceArray = [WSAppData getObjectbyKey:DUTY_OTHERSATTENDANCE];
    if (othersAttendanceArray && [othersAttendanceArray.otherAttendanceArray count] > 0) {
           return [NSArray arrayWithArray:othersAttendanceArray.otherAttendanceArray];
    }
    return nil;
}

- (BOOL) checkValue :(NSArray *)redisDatas andDictBean:(WSDictBean *) dictBean andTitle:(NSString *)title
{
    if (!title || [title length] < 1 ) {
        return NO;
    }
    
    if (!redisDatas || !dictBean) {
        return  NO;
    }
    __block BOOL isCheked = NO;
    NSString *biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [redisDatas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSOthersAttendanceBean *bean = (WSOthersAttendanceBean *)obj;
        if (bean.ODTYPE_ID == [dictBean.Id integerValue]
            && [bean.DOC_DATE isEqualToString:biz_date]
            && [bean.ODTIME_NAME isEqualToString:title]
            && [bean.atdc_value isEqualToString:@"1"]) {
            isCheked = YES;
        }
        
    }];
//    NSLog(@"title = %@ name = %@ ischecked = %d" ,title ,dictBean.name,isCheked);
    return isCheked;
}

-(void)scaleCurrentText:(WSHTextField *)currentField{
    
}

-(void)endCurrentEdit:(WSHTextField *)currentField{
    
    NSLog(@"RUN XXX1");
    
    //[memo resignFirstResponder];
    

}

-(void)cancelCurrentEdit:(WSHTextField *)currentField{
      NSLog(@"RUN XXX2");
    //[memo resignFirstResponder];
}

- (BOOL)isValueChange{
    
    BOOL flag = NO;
    flag = [self checkIsValueChange];
    NSArray *fdtDataArray = [[WSFdtTable sharedTable] queryFdtWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:self.currentStore.srid];
    WSFdtObject *fdtObject = nil;
    if (fdtDataArray != nil && [fdtDataArray count] > 0) {
        fdtObject = [fdtDataArray objectAtIndex:0];
    }
    if (memo.text.length >0 && ![memo.text isEqualToString:NSLocalizedString(@"w_task_remark", nil)] && ![memo.text isEqualToString:fdtObject.memo8]) {
        flag = YES;
    }

    
   return flag;
}

//获取考勤回显数据
- (NSArray *)getDisDicDatas{
    
    //SFA-26143 fv:TAB_V2003 为其他考勤，安卓单独的一张表使用empid和日期存取，iOS使用fv单独做处理
    //回显数据
    return  [[WSFdtTable sharedTable] queryDictWithStoreId:self.currentStore.Id fc:self.currentFuncs.fv srid:self.currentStore.srid withMd5:nil];
}

- (BOOL)checkIsValueChange{
    
    BOOL flag = NO;
    //获取考勤回显数据
    NSArray *dicDatas = [self getDisDicDatas];

    
    for (int i = 0; i < [self.datas count]; i++) {
        NSArray *subarray = [self.datas objectAtIndex:i];
        WSDictObject *object = nil;
        if (dicDatas != nil && [dicDatas count] >i) {
            object = [dicDatas objectAtIndex:i];
        }
        if ([subarray isKindOfClass:[NSArray class]]) {
            for (int j = 1; j < [subarray count]; j++) {
                id obj = [subarray objectAtIndex:j];
                NSString *disValue = [object valueForKey:[NSString stringWithFormat:@"col%i",j]];
                if ([obj isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)obj;
                    
                    NSString *currentValue = [NSString stringWithFormat:@"%d",button.isSelected];
                    
                    if ([currentValue isEqualToString:@"1"] && ![currentValue isEqualToString:disValue]) {
                        
                       return  flag = YES;
                    }else if ([currentValue isEqualToString:@"0"] && [disValue isEqualToString:@"1"]){
                       return  flag = YES;
                    }
                }
            }
        }
    }
    return flag;

}

#pragma mark - 执行lua脚本

- (void)executeLuaScripWithiRow:(NSString *)row andScrip:(NSString *)script
{
    WSLuaScriptContext *luaParserObjTest = [[WSLuaScriptContext alloc] initWithFuncsBean:self.currentFuncs
                                                                           withStoreBean:self.currentStore
                                                                                withAcvt:nil];

    luaParserObjTest.luaScriptStr = script;
    WSLuaScriptEnter *luaEnter = [[WSLuaScriptEnter alloc] init];
    [[WSLuaExecutorManager shareInstance] setCurrentoperator:self];
    [luaEnter initializationLuaContextWithLuaScriptContext:luaParserObjTest];
    [luaEnter runUniversalLuaFunction:[NSString stringWithValue:row]];
}

- (NSString *)getTableColValueByProId:(NSString *)prodId col:(NSString *)parmCol{
    
    for (int i = 0; i < self.datas.count; i++) {
        NSInteger col = [self.titles indexOfObject:parmCol]; // 第几列
        NSArray * row = self.datas[i];   // 每一行
        
        for (int j = 0 ; j < row.count; j++) {
            UIView * view = row[j];
            if ([view isKindOfClass:[WSCheckBox class]]) {
                WSCheckBox * checkBox = (WSCheckBox *)view;
                if (checkBox.iRow == [prodId intValue]) {     // 根据行号找到这一行
                    WSCheckBox * targetCheckBox = row[col];
                    if (targetCheckBox.isSelected) {          // 根据列号找到这一项返回 结果

                        return @"1";
                    }else{
                        return @"0";
                    }
                    return @"";
                }
            }
        }
    }
    return @"";
}


- (void)setTableColValueByProId:(NSString *)prodId textValue:(NSString *)text  col:(NSString *)parmCol {
    
    for (int i = 0; i < self.datas.count; i++) {
        NSInteger col = [self.titles indexOfObject:parmCol]; // 第几列
        NSArray * row = self.datas[i];   // 每一行
        
        for (int j = 0 ; j < row.count; j++) {
            UIView * view = row[j];
            if ([view isKindOfClass:[WSCheckBox class]]) {
                WSCheckBox * checkBox = (WSCheckBox *)view;
                if (checkBox.iRow == [prodId intValue]) {     // 根据行号找到这一行
                    WSCheckBox * targetCheckBox = row[col];
                    if ([text isEqualToString:@"1"]) {
                        [targetCheckBox setSelected:YES];
                    }else{
                        [targetCheckBox setSelected:NO];

                    }
                    
                    return;
                }
            }
        }
    }

}

@end
