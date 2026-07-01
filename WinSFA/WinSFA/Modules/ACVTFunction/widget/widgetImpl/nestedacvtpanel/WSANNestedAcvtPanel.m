//
//  WSANNestedAcvtPanel.m
//  WinSFA
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSANNestedAcvtPanel.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "WSEmbeddedNewAcvtViewController.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_DisplayValue.h"
#import "WSANTableView.h"
#import "WSAcvtDisBean.h"
#import "WSAcvtDisQstBean.h"
#import "WSStoreAcvtDisBean.h"
#import "WSStringValueChangeChecker.h"
#import "WSArrayValueChangeChecker.h"
#import "WSEnvrionment.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSAcvtListDataItem.h"
#import "WSAcvtDBService.h"
#import "I_W_DataSource.h"
#import "WSANAcvtTableView.h"
#import "WSANActivityTableView.h"
#import "WSANActivityModel.h"
#import "WSANActivityHeader.h"


#define kDefaultHeight          (INTERFACE_IS_PAD ? MAIN_CELL_HEIGHT : MAIN_CELL_HEIGHT)
#define kViewGap                    5.0f
#define kArrowImageViewWidth        19.0f
#define kArrowImageViewHeight       19.0f


@interface WSANNestedAcvtPanel () <WSANTableViewDelegate>

@property (nonatomic, strong) WSANTableView *tableView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) WSANAcvtTableView *acvtVCTableView;       //新加一个tableview
@property (nonatomic, strong) WSAcvtModel *currentAcvtModel;
@property (nonatomic, strong) NSMutableArray *acvtVCAcvtDatas;          //嵌套问卷acvtdatas
@property (nonatomic, strong) NSMutableArray *originalAcvtVCAcvtDatas;  //原始嵌套问卷acvtdatas
@property (nonatomic, assign) float acvtVCHight;                        //问卷控制器的高度
@property (nonatomic, assign) float acvtVCCellHeight;                   //问卷Cell的高度

//新的活动样式table，可以展开，关闭
@property (nonatomic, strong) WSANActivityTableView * activityTableView;
//新的活动样式数据源
@property (nonatomic, strong) NSMutableArray <WSANActivityModel*>* activityDataArray;


@end

@implementation WSANNestedAcvtPanel

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    self.nestedAcvtBean = [service queryAcvtWithAcvtID:[xbuildInfo getAcvtNestId]];
    
    [self.nestedAcvtBean setParentReadonly:[xbuildInfo getReadOnly]];
    
    self.xvalueChangeChecker = [[WSArrayValueChangeChecker alloc] init];
    
    if (INTERFACE_IS_PAD && self.nestedAcvtBean) {
        
        [self removeAllSubviews];
        
        self.tableView = [[WSANTableView alloc] initWithFrame:self.bounds];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView.acvtBean = self.nestedAcvtBean;
        self.tableView.readonly = [[xbuildInfo getReadOnly] boolValue];
        self.tableView.delegate = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
        
        if ([self.tableView.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
            self.tableView.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        
#endif
        [self addSubview:self.tableView];
        
    }else {
        if (self.nestedAcvtBean) {
            if([self isShowInMain]) {
                if(NO)
                {
                    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, kDefaultHeight)];
                    backView.backgroundColor = [UIColor whiteColor];
                
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, kDefaultHeight)];
                
                    [button addTarget:self action:@selector(cellTapped) forControlEvents:UIControlEventTouchUpInside];
                    self.button = button;
                
                    NSString *title = [xbuildInfo getQuestName];
                    [button setTitle:title forState:UIControlStateNormal];
                    UIFont *font;
                    if (![[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_SMALL]) {
                        font = [UIFont systemFontOfSize:UI_Font];
                    } else {
                        font = [UIFont systemFontOfSize:(UI_Font - 1)];
                    }
                    CGSize size = [title stringSizeWithFont:font width:self.width];
                    float buttonWidth  = size.width +40;
                    float buttonX = (self.width - buttonWidth)/2;
                    button.frame = CGRectMake(buttonX, 7, buttonWidth, kDefaultHeight-8);
                    button.titleLabel.font = font;
                    [button setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
                    button.layer.cornerRadius = 6;
                    button.layer.borderWidth = 1.0;
                    button.layer.borderColor = [[UIColor colorWithHexString:@"0xd4d4d4"] CGColor];
                    button.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
                    [backView addSubview:button];
                    [self addSubview:backView];
                }else{
//                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, kDefaultHeight)];
//                    [button setImageEdgeInsets:UIEdgeInsetsMake((kDefaultHeight - kArrowImageViewHeight)/2, self.width - MAIN_CELL_PADDING - kArrowImageViewWidth, (kDefaultHeight - kArrowImageViewHeight)/2, 0)];
//                    [button setImage:[UIImage imageNamed:@"jia_button"] forState:UIControlStateNormal];
//                    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                    [button setBackgroundColor:[UIColor clearColor]];
//                    [button addTarget:self action:@selector(cellTapped) forControlEvents:UIControlEventTouchUpInside];
//                    self.button = button;
//                    [self addSubview:button];

                }
                
            }else {
                if ([self isShowActivityStyle]) {
                    
                    //记录当前的acvtmodel ，在加号新增问卷中，会用到
                    self.currentAcvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
                    
                    [self setupActivityUI];
                    
                    if (self.acvtMd5Array.count>0) {
                        [self setupActivityData];
                    }
                    [self reloadActivityTableView];
                    
                }else{
                    
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, kDefaultHeight)];
                    [button setImageEdgeInsets:UIEdgeInsetsMake((kDefaultHeight - kArrowImageViewHeight)/2, self.width - MAIN_CELL_PADDING - kArrowImageViewWidth, (kDefaultHeight - kArrowImageViewHeight)/2, 0)];
                    [button setImage:[UIImage imageNamed:@"jia_button"] forState:UIControlStateNormal];
                    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button addTarget:self action:@selector(cellTapped) forControlEvents:UIControlEventTouchUpInside];
                    self.button = button;
                    [self addSubview:button];
                }
            }
        }
        
        if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
            [self.button setEnabled:NO];
            [self.rightArrowImageView setHidden:YES];
        }
        CGRect labelFrame = self.titleLabel.frame;
        labelFrame.origin.y = (kDefaultHeight - labelFrame.size.height)/2;
        self.titleLabel.frame = labelFrame;
    }
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"halfOnly"]) {
        self.button.hidden = YES;
    }
    
    if ([self isShowActivityStyle]) {
        
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kDefaultHeight);
        
        //记录当前的acvtmodel ，在加号新增问卷中，会用到
        self.currentAcvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    }
}

- (void)widgetDidLoadFinish
{
    [self reloadTableView];
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    [self.button setEnabled:![[xbuildInfo getReadOnly] boolValue]];
    
    [self.rightArrowImageView setHidden:[[xbuildInfo getReadOnly] boolValue]];
    
    [self.nestedAcvtBean setParentReadonly:[xbuildInfo getReadOnly]];
    
    self.tableView.readonly = [[xbuildInfo getReadOnly] boolValue];
    
}

- (NSString *)getMd5ByIndex:(NSInteger)index {
    NSString *md5 = nil;
    if (INTERFACE_IS_PAD) {
        if (self.acvtMd5Array.count > index) {
            md5 = [self.acvtMd5Array objectAtIndex:index];
        }
    } else {
        if (self.tableView.dataArray.count > index) {
            WSAcvtListDataItem *item = self.tableView.dataArray[index];
            md5 = item.genID;
        }
    }
    return md5;
}

- (void)performClickButton:(id)sender {
    
    if([self isShowActivityStyle]){
        
        [self setupActivityData];
        
        [self reloadActivityTableView];
        return;
    }

    NSString *md5 = [self getMd5ByIndex:0];
    [self gotoAcvtViewController:md5];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.button.hidden && [self.button pointInside:point withEvent:event]) {
        return self.button;
    }
    
    return [super hitTest:point withEvent:event];
}
- (BOOL)isShowInMain {
    return [[xbuildInfo getDisplayMode] containsString:@"showInMain"];
}
- (BOOL)mainIsDelete {
    return [[xbuildInfo getDisplayMode] containsString:@"halfReadonly"];
}
//新的活动样式
- (BOOL)isShowActivityStyle{
    return [[xbuildInfo getDisplayMode] containsString:@"showActivityStyle"];
}

- (void)reloadTableView
{
    
    if ([self isShowInMain]) {
        [self reloadShowInMainAcvtTableView];
        return;
    }
    if ([self isShowActivityStyle]) {
            
        [self reloadActivityTableView];
        
        return;
    }

    if (!self.tableView) {

        WSANTableView *tableView = [[WSANTableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        
        tableView.delegate = self;
        
        tableView.acvtBean = self.nestedAcvtBean;
        
        tableView.readonly = [[xbuildInfo getReadOnly] boolValue];
        
        self.tableView = tableView;
        
        [self addSubview:tableView];
    }
    
    CGFloat oldViewheight = [self.tableView tableViewHeight];
    
    self.tableView.embeddedAcvtsMD5 = [self.acvtMd5Array mutableCopy];
    
    if (!(INTERFACE_IS_PAD && self.nestedAcvtBean)) {
        NSArray *acvtListItemArray = [self getAcvtListItemArray];
        
        self.tableView.dataArray = [acvtListItemArray mutableCopy];
        
        
        if (acvtListItemArray.count > 0) {
            self.tableView.hidden = NO;
        }else {
            self.tableView.hidden = YES;
        }
    }
    
    
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"halfOnly"] && self.tableView.dataArray.count == 0) {
        self.frame = CGRectZero;
        return;
    }
    CGFloat newViewheight = [self.tableView tableViewHeight];
    
    if (!(INTERFACE_IS_PAD && self.nestedAcvtBean)) {
        if (newViewheight != oldViewheight) {
            CGFloat tableviewY = kDefaultHeight;
            if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
                tableviewY = 0;
            }
            self.tableView.frame = CGRectMake(0, tableviewY, self.width, newViewheight);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tableviewY + newViewheight);
        }
    }else {
        if (self.fixedHeight){
            self.tableView.frame = self.bounds;
        }else {
            if (newViewheight != oldViewheight) {
                self.tableView.frame = CGRectMake(0, 0, self.width, newViewheight);
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newViewheight);
            }
        }
    }
}

- (NSArray *)getAcvtListItemArray
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    
    //    SFA-18814 donghong
    //    SFA 项目SFA-22610  wanghaipeng【SFA泸州老窖】（这里和安卓对逻辑没有这个isFromRemote的判断，因为这个参数出新BUG再一起讨论下这块儿逻辑)
    BOOL isFromRemote = YES;
    
    NSArray *dbItemArray = [service queryAcvtDatasWithStoreID:model.currentStore.Id acvtType:self.nestedAcvtBean.typ searchText:nil genIDs:self.acvtMd5Array
                                                       isRead:NO isRemoteSearch:isFromRemote acvtSort:@"0"];
    
    //重排序
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.acvtMd5Array.count; i++)
    {
        NSString *md5 = self.acvtMd5Array[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.genID = %@",md5];
        NSArray *filterArray = [dbItemArray filteredArrayUsingPredicate:predicate];
        if ([filterArray count] > 0)
            [resultArray addObject:[filterArray firstObject]];
    }
    //MN-3815
    self.acvtDataArray = resultArray;
    
    //SFA-25257 客户管理中三个协议的嵌套问卷个性化修改(根据memo2来字段判断取最新的一条数据回显)
//    if ([[xbuildInfo getAcvtMemo2] isEqualToString:@"newest"]) {
//        if (resultArray.count > 0) {
//            NSMutableArray *tmpArray = [NSMutableArray arrayWithObject:[resultArray lastObject]];
//            return tmpArray;
//        }
//    }
    
    return resultArray;
}



- (void)cellTapped
{
    // SFA-23507 CLONE - 剑南春项目--新增网点模块，终端类型不同，联系人职位选择不同
    
    if ([self isShowInMain]) {
        
        [self crateWithmd5:nil];
        
        [self reloadTableView];
        
    } else {

    if ([[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    
    WSAcvtBean_qst *qst = (WSAcvtBean_qst *)self.xbuildInfo;
    
    if (qst.mlen && qst.mlen.length > 0 && ![qst.mlen isEqualToString:@"0"]) {
        if (self.acvtDataArray && self.acvtDataArray.count >= [qst.mlen integerValue]) {
            [self showOverMaxNumHud];
        }else
            [self gotoAcvtViewController:nil];
    }else
        [self gotoAcvtViewController:nil];
    
    }
}

// 添加超过最大数量弹出提示
- (void)showOverMaxNumHud
{
//    NSString *errorString = NSLocalizedString(@"time_check_error_lable",nil);
    NSString *errorString = NSLocalizedString(@"已达到添加数量上限",nil);
    
    [MBProgressHUD showHUDAddedTo:self withText:errorString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.0];
    
}

- (void)gotoAcvtViewController:(NSString *)md5 {
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    if (INTERFACE_IS_PAD) {
        [interaction setDirect_type:DIRECT_TYPE_POPOVER];
    }else {
        [interaction setDirect_type:DIRECT_TYPE_PUSH];
    }
    
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    [self.nestedAcvtBean setParentReadonly:[xbuildInfo getReadOnly]];
    [self.nestedAcvtBean setParentgenId:model.md5];
    [self.nestedAcvtBean setAcvtParentQstId:[xbuildInfo getAcvtQstId]];
    [self.nestedAcvtBean setParentAcvtId:model.currentAcvtBean.acvtId];
    [self.nestedAcvtBean setParentQstCode:[xbuildInfo getQstCode]];
    WSEmbeddedNewAcvtViewController *acvtCon = [[WSEmbeddedNewAcvtViewController alloc] initWithAcvt:self.nestedAcvtBean Funcs:model.currentFuncs Store:model.currentStore md5:md5];
    acvtCon.parentModel = model;
    acvtCon.memo2 = [xbuildInfo getAcvtMemo2];
    NSString *title;
    if (self.nestedAcvtBean.acvtName) {
        title = self.nestedAcvtBean.acvtName;
    } else {
        title = self.titleLabel.text;
    }
    acvtCon.title = title;
    acvtCon.delegate = self;
    acvtCon.prepareVisitDate = model.prepareVisitDate;
    
    [interaction setExecute_controller:acvtCon];
    
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
}

- (NSObject *)getResultDirectly
{
    // SFA-28665 【SFA泸州老窖】【iOS】上传门店详情问卷时，会上传多余的问题且是空值
    
    if([self isShowInMain]) {
        return [self getSubAcvtViewDatas];
    }
    if([self isShowActivityStyle]) {
        return [self getSubAcvtViewDatas];
    }
    if (self.acvtDataArray.count > 0) {
        return self.acvtDataArray;
    }
    return nil;
}

- (NSObject *)getCurrentValueForID {
    return [self getCurrentValue];
}

- (NSObject *)getResultPresentation
{
    if ([self.acvtDataArray count] > 0) {
        return [self.acvtDataArray JSONString];
    }
    
    return nil;
}

// 跟安卓一致
- (NSObject *)getCurrentValue {
    
    if ([self.acvtDataArray count] > 0) {
        NSString *currentValue = @"";
        for (int i = 0; i < self.acvtDataArray.count; ++i) {
            NSDictionary *dic = [self.acvtDataArray objectAtIndex:i];
            NSString *genId = nil;
            if (i == self.acvtDataArray.count - 1) {
                genId = [NSString stringWithFormat:@"%@", dic[@"id"]];
            } else {
                genId = [NSString stringWithFormat:@"%@,", dic[@"id"]];
            }
            currentValue = [currentValue stringByAppendingString:genId];
        }
        return currentValue;
    } else {
        return nil;
    }
}

- (void)setValueChange:(BOOL)isValueChange {
    
    if ([[xbuildInfo getIsHidden] isEqualToString:@"1"]) {
        return;
    }
    
    if (isValueChange) {
        if ([self.delegate respondsToSelector:@selector(widget:valueChanged:)]) {
            [self.delegate widget:self valueChanged:isValueChange];
        }
    }
    
    
}


- (void)setRightViewHidden:(NSString *)isHidden {
    if ([isHidden isEqualToString:@"1"] || [isHidden isEqualToString:@"true"]){
        [self.button setHidden:YES];
    } else {
        [self.button setHidden:NO];
    }
}


- (BOOL)saveEmbeddedAcvtDatasToDB:(NSDictionary *)dataDic md5:(NSString *)md5
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *bizDate = model.prepareVisitDate ? model.prepareVisitDate : [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
   
    
    return [WSAcvtDBService insertAcvtDatasToDBWithStore:model.currentStore newStoreBean:nil acvtBean:self.nestedAcvtBean qstValueDic:dataDic qstValueDicKeyType:WSAcvtQstValueDicKeyTypeQstTypeAndAcvtqstID funcCod:model.currentFuncs.fc md5:md5 bizDate:bizDate];
}

- (void)saveDeleteWhenUpload
{
    if ([self.deleteMD5Array count] > 0) {
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        for (NSString *md5 in self.deleteMD5Array) {
            [service deleteLocalDataWithGenId:md5];
        }
    }
    
    [self.deleteMD5Array removeAllObjects];
    [self.anNewAddMD5Array removeAllObjects];
}

- (void)deleteNewAddDatasWhenRevert
{
    if ([self.anNewAddMD5Array count] > 0) {
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        for (NSString *md5 in self.anNewAddMD5Array) {
            [service deleteLocalDataWithGenId:md5];
        }
    }
}
- (void)setHeaderValue:(NSString*)value{
    LogInfo(@"区头标题：%@",value);
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    if ([valuePresentation length] > 0) {
        [self loadRedisDataWithValue:valuePresentation];
    } else {
        [self.acvtMd5Array removeAllObjects];
        [self.acvtDataArray removeAllObjects];
        [self.acvtVCArray removeAllObjects];
        
        if ([self isShowActivityStyle]) {
            [self.activityDataArray  removeAllObjects];
        }
    }
    
    if ([self isShowActivityStyle]) {
        if (self.acvtMd5Array.count>0) {
            [self setupActivityData];
        }
        [self reloadActivityTableView];
    }else{
        [self reloadTableView];
    }

}
- (void)setEmpId:(NSString *)empId{
    
    if (empId.length < 1) {
        return ;
    }
    self.tempEmpId = empId;
}


#pragma mark - WSEmbeddedAcvtViewControllerDelegate

- (void)embeddedAcvtController:(WSEmbeddedAcvtViewController *)controller confirmData:(NSDictionary *)dic
{
    [super embeddedAcvtController:controller confirmData:dic];
   
    BOOL isValueChange = [controller isValueChange];
    
    if (isValueChange) {
        [self setValueChange:YES];
    }
    
    [self reloadTableView];
    
}

#pragma mark - WSANTableViewDelegate
- (void)anTableView:(WSANTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *md5 = [self getMd5ByIndex:indexPath.row];
    [self gotoAcvtViewController:md5];
}

- (void)anTableView:(WSANTableView *)tableView didDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *deleteMd5 = [self.acvtMd5Array objectAtIndex:indexPath.row];
    if (deleteMd5) {
        [self.deleteMD5Array addObject:deleteMd5];
    }
    
    [self.acvtDataArray removeObjectAtIndex:indexPath.row];
    [self.acvtMd5Array removeObjectAtIndex:indexPath.row];
    
    [self setValueChange:YES];
    
  
    [self.tableView statisticsViewHeight];
    
    CGFloat newViewheight = [self.tableView tableViewHeight];
    
    if (!(INTERFACE_IS_PAD && self.nestedAcvtBean)) {
        self.tableView.frame = CGRectMake(0, kDefaultHeight, self.width, newViewheight);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kDefaultHeight + newViewheight);
    }else if (!self.fixedHeight){
        self.tableView.frame = CGRectMake(0, 0, self.width, newViewheight);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newViewheight);
    }
}

- (void)anTableViewAddButtonClicked:(WSANTableView *)tableView
{
    [self cellTapped];
}

- (void)anTableView:(WSANTableView *)tableView leftTitleQst:(WSAcvtBean_qst *)leftTitleQst isSelected:(BOOL)selected md5:(NSString *)md5
{
    NSInteger index = [self.acvtMd5Array indexOfObject:md5];
    NSMutableDictionary *dic = [self.acvtDataArray[index] mutableCopy];
    NSString *key = [NSString stringWithFormat:@"%@%@", leftTitleQst.qstType, leftTitleQst.acvtQstId];
    if (selected) {
        [dic setObject:[(WSAcvtBean_qst_opt *)[leftTitleQst.opt firstObject] optId] forKey:key];
    }else {
        [dic removeObjectForKey:key];
    }
    
    [self saveEmbeddedAcvtDatasToDB:dic md5:md5];
    
    [self.acvtDataArray replaceObjectAtIndex:index withObject:dic];
    
    [self setValueChange:YES];
}


-(void)updateViewDisplayDatas:(NSString *)data{

    if ([data isEqualToString:@"halfReadonly"]) {
        self.button.hidden = YES;
    }
}

-(NSString *)getDataCount{
    return [NSString stringWithFormat:@"%ld",self.tableView.dataArray.count];
}

-(void)setClickable:(NSString *)isClick{
    if ([isClick isEqualToString:@"false"] || [isClick isEqualToString:@"0"]) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
}

// SFA-18189 脚本调用隐藏方法导致此控件高度计算错误，故在子类重写此方法
- (void)setWidgetHidden:(NSString *)isHidden
{
    NSString *hiddenString = @"0";
    BOOL hidden = NO;
    
    if([isHidden isEqualToString:@"1"] || [isHidden isEqualToString:@"true"]){
        hiddenString = @"1";
        hidden = YES;
    }
    
    [xbuildInfo setIsHidden:hiddenString];
    
    self.hidden = hidden;
    
    if (self.hidden) {
        self.frame = CGRectZero;
    }else {
        [self reloadTableView];
//        SFA-19413
//        SFA-广福来-ios：考察门店填加数据再次方面查看不到数据
         if (self.acvtDataArray.count <= 0) {
             self.frame = [xbuildInfo getLayOutInfo];
         }
        
    }
    [self.superview layoutSubviews];
}

#pragma -mark - 玛氏新需求功能实现 2018/12/14 ---zhangmin MMSH-8185

//点击加号按钮 新增问卷
- (void)crateWithmd5:(NSString *)md5 {
    
    WSAcvtModel *model = self.currentAcvtModel;
    
    [self.nestedAcvtBean setParentReadonly:[xbuildInfo getReadOnly]];
    [self.nestedAcvtBean setParentgenId:model.md5];
    [self.nestedAcvtBean setAcvtParentQstId:[xbuildInfo getAcvtQstId]];
    [self.nestedAcvtBean setParentAcvtId:model.currentAcvtBean.acvtId];
    
    self.nestedAcvtBean.empId = self.tempEmpId;
    
    WSEmbeddedNewAcvtViewController *acvtCon = [[WSEmbeddedNewAcvtViewController alloc] initWithAcvt:self.nestedAcvtBean Funcs:model.currentFuncs Store:model.currentStore md5:md5];
    acvtCon.parentModel = model;
    
    acvtCon.delegate = self;
    acvtCon.prepareVisitDate = model.prepareVisitDate;
    acvtCon.isAsView = YES;
    //没有高度的时候才在acvtviewcontroller中预加载acvtview，便于获取高度
    if (self.acvtVCHight <= 0) {
        acvtCon.loadAcvtViewFormViewDidLoad = YES;// 在viewdidload中加载问卷
        CGRect  frame = acvtCon.view.frame;
        if (self.tempEmpId && self.tempEmpId.length > 0 && [self.tempEmpId containsString:@","]&& !md5) {
            self.acvtVCHight = acvtCon.acvtview.height + 44;
        }else {
            self.acvtVCHight = acvtCon.acvtview.height ;
        }
    }
    
    [self.acvtVCArray addObject:acvtCon];
    
    [self getAcvtTabbleViewCellHight ];
    
}

- (void)getAcvtTabbleViewCellHight {
    float deleteBtnHight = 44;
    if (self.tempEmpId && self.tempEmpId.length > 0 && [self.tempEmpId containsString:@","]) {
        _acvtVCCellHeight = self.acvtVCHight - 44 + deleteBtnHight ;
    }else {
        _acvtVCCellHeight = self.acvtVCHight + deleteBtnHight;
    }
}

//刷新acvtVCtableView
- (void)reloadShowInMainAcvtTableView {
    if (!self.acvtVCTableView) {
        
        WSANAcvtTableView *tableView = [[WSANAcvtTableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        
        //        tableView.delegate = self;
        
        tableView.acvtBean = self.nestedAcvtBean;
        
        tableView.readonly = [[xbuildInfo getReadOnly] boolValue];
        
        tableView.mainIsDelete = [self mainIsDelete];
        
        self.acvtVCTableView = tableView;
        
        [self addSubview:tableView];
        
        for (int i = 0; i < self.acvtDataArray.count; i ++) {
            
            NSString * md5 = [self.acvtMd5Array objectAtIndex: i];
            
            [self crateWithmd5:md5 ];
        }
    }
    
    self.acvtVCTableView.cellHight = _acvtVCCellHeight;
    self.acvtVCTableView.acvtVCArray = self.acvtVCArray;
    
    CGFloat acvtTableViewHeight = _acvtVCCellHeight * self.acvtVCArray.count;
    
    CGFloat tableviewY = kDefaultHeight;
    if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
        tableviewY = 0;
    }
    self.acvtVCTableView.frame = CGRectMake(0, tableviewY, self.width, acvtTableViewHeight);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tableviewY + acvtTableViewHeight);
    
}
#pragma mark - ******************（新的嵌套活动UI）分割线********************
#pragma mark - # 新的活动嵌套问卷TableUI
- (void)setupActivityUI{
    
    [self activityTableView];
    
}
#pragma mark - # 新的活动嵌套问卷Data处理
- (void)setupActivityData{
    
    if (self.acvtMd5Array.count==0) {
        LogDebug(@"第一次进入活动页面，本次无活动，需要自动添加一次活动");
        [self crateActivityViewDataWithMd5:nil];
        
    }else{
        LogDebug(@"非首次进入活动页面，回显本地嵌套活动或者服务器嵌套活动");
        for (int i = 0; i < self.acvtDataArray.count; i ++) {
            if (i < self.acvtMd5Array.count) {
                NSString * md5 = [self.acvtMd5Array objectAtIndex: i];
                [self crateActivityViewDataWithMd5:md5];
            }else{
                LogError(@"数据越界，请检查数据");
            }
        }
    }
}
#pragma mark - # 更新新的活动嵌套问卷TableData And Frame
- (void)reloadActivityTableView {
    
    
    self.activityTableView.acvtVCArray = self.activityDataArray;
    
    CGFloat acvtTableViewHeight = kActivityHeight;
    CGFloat acvtTableViewHeaderH = kActivityHeaderHeight;
    for (WSANActivityModel * activityModel in self.activityDataArray) {
        acvtTableViewHeight += acvtTableViewHeaderH;
        if (activityModel.isExpand) {
            acvtTableViewHeight += activityModel.cellHeight;
        }else{
            acvtTableViewHeight += kNotExpandTableCellHeight;
        }
    }
    
    CGFloat tableviewY = kDefaultHeight;
    if ([[xbuildInfo getIsHideQstName] isEqualToString:@"1"]) {
        tableviewY = 0;
    }
    CGFloat footHeight = kActivityFootererHeight + kActivityFootererSpace * 2 ;
    
    self.activityTableView.frame = CGRectMake(kActivitySpace, tableviewY, self.width, acvtTableViewHeight + footHeight);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tableviewY + acvtTableViewHeight + footHeight);
    
    [xbuildInfo setLayOutInfo:self.frame];
    
    [self setNeedsLayout];
    
    [self.superview setNeedsLayout];
}
#pragma mark - # Register Block
- (void)addActivityTableViewBlock{
    
    @weakify_self;
    [self.activityTableView addNewANActivityBlock:^{
        
        @strongify_self;
        if (self.acvtDataArray && self.acvtDataArray.count >= [[xbuildInfo getMlen] integerValue] && ![[xbuildInfo getMlen] isEqualToString:@"0"]) {
            LogError(@"嵌套问卷超过最大可添加数量");
            [self showOverMaxNumHud];
            return;
        }
        if ([self.getReadonly boolValue]) {
            LogError(@"问卷只读");
            return;
        }
        [self crateActivityViewDataWithMd5:nil];
        [self reloadActivityTableView];
    }];
    
    [self.activityTableView deleteActivityBlock:^(NSIndexPath * _Nullable selectIndexPath) {
        @strongify_self;
        NSInteger index = selectIndexPath.section;
        // 先删除数据源
        if (index >= 0 && index < self.acvtVCArray.count) {
            
            if ([self.getReadonly boolValue]) {
                LogError(@"问卷只读");
                [SVProgressHUD showHudMsg:@"当前状态不允许删除"];
                return;
            }
            
            [self.acvtVCArray removeObjectAtIndex:index];
            [self.activityDataArray removeObjectAtIndex:index];
            [self reloadActivityTableView];
        }
    }];
    
    [self.activityTableView expandActivityHandler:^(NSIndexPath * _Nullable selectIndexPath, BOOL isExpand) {
        @strongify_self;
        NSInteger index = selectIndexPath.section;
        if (index >= 0 && index < self.activityDataArray.count) {
            WSANActivityModel * model = self.activityDataArray[index];
            if (isExpand) {
                model.isExpand = YES;
            }else{
                model.isExpand = NO;
            }
            [self.activityDataArray replaceObjectAtIndex:index withObject:model];
            [self reloadActivityTableView];
        }
    }];
}
#pragma mark - # 新的活动嵌套问卷Data
- (void)crateActivityViewDataWithMd5:(NSString *)md5 {
    
    
    WSAcvtModel *model = self.currentAcvtModel;
    [self.nestedAcvtBean setParentReadonly:[xbuildInfo getReadOnly]];
    [self.nestedAcvtBean setParentgenId:model.md5];
    [self.nestedAcvtBean setAcvtParentQstId:[xbuildInfo getAcvtQstId]];
    [self.nestedAcvtBean setParentAcvtId:model.currentAcvtBean.acvtId];
    self.nestedAcvtBean.empId = self.tempEmpId;
    WSEmbeddedNewAcvtViewController *acvtCon = [[WSEmbeddedNewAcvtViewController alloc] initWithAcvt:self.nestedAcvtBean Funcs:model.currentFuncs Store:model.currentStore md5:md5];
    acvtCon.parentModel = model;
    acvtCon.delegate = self;
    acvtCon.prepareVisitDate = model.prepareVisitDate;
    acvtCon.isAsView = YES;
    acvtCon.loadAcvtViewFormViewDidLoad = YES;
    @weakify_self;
    void(^reloadHeaderTitleBlock)(NSString *headerTitle, WSEmbeddedNewAcvtViewController *vc) = ^(NSString *headerTitle, WSEmbeddedNewAcvtViewController *vc){
        LogDebug(@"区头：%@",headerTitle);
        LogDebug(@"lx@33333333->：%@",vc.acvtview);
        @strongify_self;
        [self p_updateActivityTableViewHeader:headerTitle vc:vc];
    };
    [acvtCon setReloadHeaderTitleBlock:reloadHeaderTitleBlock];
    
    WSANActivityModel * activityModel = [[WSANActivityModel alloc]init];
    activityModel.controller = acvtCon;
    activityModel.isExpand = YES;
    activityModel.activityTitle = kActivityDefaultTitle;
    CGFloat cellHeight = 0.0;
    // 在viewdidload中加载问卷
    CGRect  frame = acvtCon.view.frame;
    cellHeight = acvtCon.acvtview.height;
    activityModel.cellHeight = cellHeight + kTableCellPad * 2;
    //acvtVCArray只存储VC
    [self.acvtVCArray addObject:acvtCon];
    [self.activityDataArray addObject:activityModel];
   
}
#pragma mark - # 区头标题更新
- (void)p_updateActivityTableViewHeader:(NSString*)hederTitle vc:(WSEmbeddedNewAcvtViewController*)vc{
    NSInteger index = -1;
    if (self.acvtVCArray.count>0&&[self.acvtVCArray containsObject:vc]) {
        index = [self.acvtVCArray indexOfObject:vc];
    }
    if (index>-1) {
        LogDebug(@"更新%ld区标题",index);
        WSANActivityModel * model = self.activityDataArray[index];
        model.activityTitle = hederTitle;
        model.cellHeight = vc.acvtview.height + kTableCellPad * 2;
        [self.activityDataArray replaceObjectAtIndex:index withObject:model];
        [self reloadActivityTableView];
    }
}
#pragma mark - # Public Method 更新嵌套问卷高度
- (void)updateANNestFrameWithWithSubview:(UIView*)sub height:(CGFloat)height{
    
    if(sub==nil)return;
    NSInteger subIndex = -1;
    for (NSInteger i = 0; i < self.acvtVCArray.count; i++) {
        WSEmbeddedAcvtViewController * vc = self.acvtVCArray[i];
        if(vc.acvtview == sub){
            NSLog(@"找到子view");
            subIndex = i;
            break;
        }
    }
    if(subIndex==-1){
        LogInfo(@"没有找到对应的子问卷，无法更新frame");
        return;
    }
    if(self.activityDataArray.count == 0){
        LogInfo(@"旧的嵌套问卷，无法更新frame");
        return;
    }
    WSANActivityModel * model = self.activityDataArray[subIndex];
    model.cellHeight = height + kTableCellPad * 2;
    [self.activityDataArray replaceObjectAtIndex:subIndex withObject:model];
    [self reloadActivityTableView];
}

#pragma mark - 获取嵌套问卷数据的数据方法
- (NSArray *)getSubAcvtViewDatas {
    
    NSMutableArray *uploadArr = [NSMutableArray array];
    NSMutableArray *originalUploadArr = [NSMutableArray array];
    for (int i = 0; i < self.acvtVCArray.count; i++) {
        
        WCBaseViewController *vc = self.acvtVCArray[i];
        if (![vc isKindOfClass:[WSEmbeddedNewAcvtViewController class]]) {
            continue;
        }
        
        WSEmbeddedNewAcvtViewController *newacvtVC = (WSEmbeddedNewAcvtViewController *)vc;
        NSDictionary *currentDic = [newacvtVC getAcvtData];
        
        //原始的问卷数据不存在 第一次执行getSubAcvtViewDatas 直接上传数据+图片
        if (self.originalAcvtVCAcvtDatas.count == 0) {
            
            [uploadArr addObject:currentDic];
            [originalUploadArr addObject:currentDic];
            [newacvtVC uploadPhotos];
            continue;
        }
        
        //比对缓存数据
        NSString *currentDicStr = [currentDic JSONString];
        BOOL isCache = NO;
        for (int j = 0; j < self.originalAcvtVCAcvtDatas.count; j++) {
            
            NSDictionary *dic = [self.originalAcvtVCAcvtDatas objectAtIndex:j];
            NSString *dicStr = [dic JSONString];
            if ([currentDicStr isEqualToString:dicStr]) {
                
                isCache = YES;
                break;
            }
        }
        
        //和缓存数据一致(问卷没有变化) 不需要上传图片
        if (isCache) {
            [uploadArr addObject:currentDic];
            [originalUploadArr addObject:currentDic];
            continue;
        }
        
        //和缓存数据不一致 强行更改当前数据的imageIndex后 上传数据+图片
        id photonamesDic = [currentDic objectForKey:@"photonames"];
        NSDictionary *newDic = nil;
        if ([photonamesDic isKindOfClass:[NSString class]]) {
            
            NSString *str = photonamesDic;
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            newDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        }
        else if ([photonamesDic isKindOfClass:[NSDictionary class]]) {
            
            newDic = photonamesDic;
        }
        NSString *replaces = [NSString stringWithFormat:@"%@", currentDicStr];
        for (NSString *key in newDic.allKeys) {
                                                     
            NSString *newKey = [NSString stringWithFormat:@"%@%@", key, [WSCurrentTime getTimeMillisString]];
            replaces = [replaces stringByReplacingOccurrencesOfString:key withString:newKey];
        }
        NSData *jsonData = [replaces dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *addDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        [uploadArr addObject:addDic];
        [originalUploadArr addObject:currentDic];
        [newacvtVC uploadPhotos];
    }
    
    self.acvtVCAcvtDatas = uploadArr;
    self.originalAcvtVCAcvtDatas = originalUploadArr;
    return [self.acvtVCAcvtDatas copy];
}


//这一个ShowInMain类型的校验特别处理 子问卷的校验
- (BOOL)executeValidateWithAcvtShowInMain {
    
    BOOL isOK = YES;
    
    for (int i = 0;  i < self.acvtVCArray.count; i ++) {
        WCBaseViewController *vc = self.acvtVCArray[i];
        if ([vc isKindOfClass:[WSEmbeddedNewAcvtViewController class]]) {
            WSEmbeddedNewAcvtViewController *newacvtVC = (WSEmbeddedNewAcvtViewController *)vc;
            isOK = [newacvtVC executeValidate]; //每个子问卷都要校验
            if (isOK == NO) {
                break;
            }
            
        }
    }
    
    return isOK;
}

#pragma mark - 重写getNotReqTipData方法(获取非校验提示数据)
- (NSMutableDictionary *)getNotReqTipData {
    
    NSMutableDictionary *tipDic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.acvtVCArray.count; i ++) {
        
        WCBaseViewController *vc = self.acvtVCArray[i];
        if ([vc isKindOfClass:[WSEmbeddedNewAcvtViewController class]]) {
            
            WSEmbeddedNewAcvtViewController *newacvtVC = (WSEmbeddedNewAcvtViewController *)vc;
            NSMutableDictionary *dic = [newacvtVC.acvtview getAcvtNotReqCheckTipData];
            for (NSString *key in dic.allKeys) {
                
                NSInteger number = [[tipDic objectForKey:key] integerValue];
                number += [[dic objectForKey:key] integerValue];
                [tipDic setObject:[NSNumber numberWithInteger:number] forKey:key];
            }
        }
    }
    
    return tipDic;
}

#pragma mark - # load lazy
- (WSANActivityTableView*)activityTableView{
    if (!_activityTableView) {
        _activityTableView = [[WSANActivityTableView alloc]initWithFrame:CGRectMake(0, 0, self.width, 0)];
        [self addSubview:_activityTableView];
        _activityTableView.acvtBean = self.nestedAcvtBean;
        _activityTableView.readonly = [[xbuildInfo getReadOnly] boolValue];
        [self addActivityTableViewBlock];
    }
    return _activityTableView;
}

-(NSMutableArray *)acvtVCArray {
    if (!_acvtVCArray) {
        _acvtVCArray = [NSMutableArray array];
    }
    return  _acvtVCArray;
}


#pragma mark - 获取acvtVCAcvtDatas方法
- (NSMutableArray *)acvtVCAcvtDatas {
    
    if (!_acvtVCAcvtDatas) {
        _acvtVCAcvtDatas = [NSMutableArray array];
    }
    return _acvtVCAcvtDatas;
}

#pragma mark - 获取originalAcvtVCAcvtDatas方法
- (NSMutableArray *)originalAcvtVCAcvtDatas {
    
    if (!_originalAcvtVCAcvtDatas) {
        _originalAcvtVCAcvtDatas = [NSMutableArray array];
    }
    return _originalAcvtVCAcvtDatas;
}

- (NSMutableArray *)activityDataArray {
    
    if (!_activityDataArray) {
        _activityDataArray = [NSMutableArray array];
    }
    return _activityDataArray;
}

@end

