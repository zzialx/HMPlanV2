//
//  WSTileListContentView.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTileListContentView.h"

#import "WSTileListParentTableViewCell.h"

#import "WSTileListChildrenTableViewCell.h"

#import "I_W_Children_DataSource.h"

#import "WSOrgBean.h"

#define K_TILE_BUTON_BASE_TAG  333

#define K_TABLE_BASE_TAG 1000

#define K_BUTTON_WIDTH  80

#define K_BUTTON_HEIGHT 40


#define K_BG_VIEW_HEIGHT 500


#define K_TABLE_VIEW_WIDTH 235

#define K_TABLE_VIEW_HEIGHT  370


#define K_SPERATE_LINE_Y  60


#define K_BUTTON_LEFT_SPACE  150

#define K_VIEWS_MARGIN 10

#define K_TABLE_ROW_HEIGHT 44

#define K_TABLE_SECITONS 1

#define K_TABLE_Y 60.0f

#define K_MAIN_TINIT_COLOR MAIN_TINT_COLOT

#define DATASOURCE_PREFIX_KEY  @"tile_Table_key"


#define K_TITLE_LABELY 10


#define K_TITLE_LABEL_HEIGHT 30

#define K_TITLE_LABEL_WIDTH 120

#define K_TOTAL_LABEL_X 5

#define K_TOTAL_LABEL_Y 20

#define K_TOTAL_LABEL_WIDTH 200

#define K_TOTAL_LABEL_HEIGHG  30




@interface WSTileListContentView ()<UITableViewDataSource,UITableViewDelegate,WSTileListChildrenTableCellDelegate>

@property (nonatomic,strong) NSMutableDictionary *allTableDataSource;

@property (nonatomic,strong) NSMutableArray *choseOrgs;

@property (nonatomic,strong) UIView *bgView;

@property (nonatomic,assign) NSInteger maxNum;

@property (nonatomic,strong) UILabel *totalLabel;

@end
 

@implementation WSTileListContentView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}


- (void)initData {
    
    _allTableDataSource = [[NSMutableDictionary alloc] init];
    
    _choseOrgs = [[NSMutableArray alloc] init];
}

- (void)setDataSource:(NSMutableArray *)dataSource  redisOrgs:(NSMutableArray *)redisOrgs{
    
    self.choseOrgs = redisOrgs;
    
    _dataSource = dataSource;
    
    NSString *key = [self getDataSourceKey:K_TABLE_BASE_TAG + 0];
    
    [self.allTableDataSource setObject:dataSource forKey:key];
    
}

- (void)loadSubViewsAndTableNum:(NSInteger )num qstName:(NSString *)qstName {
    
    self.maxNum = num;
    
    CGFloat BG_VIEW_WIDTH = num * K_TABLE_VIEW_WIDTH + (num - 1) * 1;
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake((self.width - BG_VIEW_WIDTH)/2, (self.height - K_BG_VIEW_HEIGHT)/2, BG_VIEW_WIDTH, K_BG_VIEW_HEIGHT)];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 5.0f;
    _bgView.layer.borderColor = [K_MAIN_TINIT_COLOR CGColor];
    _bgView.layer.borderWidth = 1.0f;
    [self addSubview:self.bgView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((BG_VIEW_WIDTH - K_TITLE_LABEL_WIDTH)/2, K_TITLE_LABELY, K_TITLE_LABEL_WIDTH, K_TITLE_LABEL_HEIGHT)];
    titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    titleLabel.text = qstName;
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:titleLabel];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(K_TOTAL_LABEL_X, K_TOTAL_LABEL_Y,K_TOTAL_LABEL_WIDTH, K_TOTAL_LABEL_HEIGHG)];
    _totalLabel.font = [UIFont systemFontOfSize:UI_Font];
    _totalLabel.textColor = [UIColor grayColor];
    _totalLabel.backgroundColor = [UIColor clearColor];
    _totalLabel.textAlignment = NSTextAlignmentLeft;
    NSString *text = [NSString stringWithFormat:@"已选择组织数(%lu)",(unsigned long)[self.choseOrgs count]];
    NSRange range = [text rangeOfString:@"("];
    NSMutableAttributedString *str = [self text:text addSpecialColor:K_MAIN_TINIT_COLOR inRange:NSMakeRange(range.location, range.length + 2)];
    _totalLabel.attributedText = str;
   
    [self.bgView addSubview:_totalLabel];
    
    UIView *sperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, K_SPERATE_LINE_Y - 1, BG_VIEW_WIDTH, 1)];
    sperateLine.backgroundColor = [UIColor grayColor];
    [self.bgView addSubview:sperateLine];
    
    for (NSInteger i = 0; i < num; i++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i * (K_TABLE_VIEW_WIDTH + 1), K_TABLE_Y, K_TABLE_VIEW_WIDTH - 2,  K_BG_VIEW_HEIGHT - K_TABLE_Y - 3*K_VIEWS_MARGIN - K_BUTTON_HEIGHT )];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.tag = K_TABLE_BASE_TAG + i;
        [self.bgView addSubview:tableView];
        
        if (i != num -1) {
            UIView *verticalSperateLine = [[UIView alloc] initWithFrame:CGRectMake((i + 1)*K_TABLE_VIEW_WIDTH, K_TABLE_Y, 1, K_TABLE_VIEW_HEIGHT)];
            
            verticalSperateLine.backgroundColor = [UIColor grayColor];
            [self.bgView addSubview:verticalSperateLine];
        }
    }
    
    
    UIView *bottomSperateLine = [[UIView alloc] initWithFrame:CGRectMake(0, K_SPERATE_LINE_Y + K_TABLE_VIEW_HEIGHT, BG_VIEW_WIDTH, 1)];
    bottomSperateLine.backgroundColor = [UIColor grayColor];;
    [self.bgView addSubview:bottomSperateLine];
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(K_BUTTON_LEFT_SPACE, K_BG_VIEW_HEIGHT - K_BUTTON_HEIGHT - 2* K_VIEWS_MARGIN, K_BUTTON_WIDTH, K_BUTTON_HEIGHT)];
    cancelButton.tag = K_TILE_BUTON_BASE_TAG;
    [cancelButton setTitleColor:K_MAIN_TINIT_COLOR forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    [self.bgView addSubview:cancelButton];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [okButton setFrame:CGRectMake(BG_VIEW_WIDTH - K_BUTTON_LEFT_SPACE - K_BUTTON_WIDTH, K_BG_VIEW_HEIGHT - K_BUTTON_HEIGHT - 2* K_VIEWS_MARGIN, K_BUTTON_WIDTH, K_BUTTON_HEIGHT)];
    okButton.tag = K_TILE_BUTON_BASE_TAG + 1;
    [okButton setTitleColor:K_MAIN_TINIT_COLOR forState:UIControlStateNormal];
    [okButton setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [self.bgView addSubview:okButton];
    
    
    if (!IOS7_OR_LATER) {
        self.bgView.transform =  CGAffineTransformMakeRotation(-M_PI/2);
    }
    
}


- (void)buttonClick:(UIButton *)button {
    
    self.tileClickBlock(button.tag,self.choseOrgs);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return K_TABLE_SECITONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *key = [self getDataSourceKey:tableView.tag];
    
    NSArray *rowObjcts =  self.allTableDataSource[key];
    
    return [rowObjcts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag ==  self.maxNum + K_TABLE_BASE_TAG - 1) {
        static NSString *cellIndentifier = @"childrenCellIndentifier";
        
        WSTileListChildrenTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if(cell==nil){
            cell=[[WSTileListChildrenTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        
        cell.cellDelegate = self;
        
        cell.tableViewTag = tableView.tag;
        
        NSArray *dataSource = self.allTableDataSource[[self getDataSourceKey:tableView.tag]];
        
        WSOrgBean<I_W_OptionDataItem,I_W_Children_DataSource> * object = dataSource[indexPath.row];
        
        [cell setObject:object];
        
        return cell;
        
    }else {
        
        static NSString *cellIndentifier = @"parentCellIndentifier";
        
        WSTileListChildrenTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if(cell==nil){
            cell=[[WSTileListChildrenTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        
        cell.cellDelegate = self;
        
        cell.tableViewTag = tableView.tag;
        
        NSArray *dataSource = self.allTableDataSource[[self getDataSourceKey:tableView.tag]];
        
        WSOrgBean <I_W_OptionDataItem,I_W_Children_DataSource> * object = dataSource[indexPath.row];
    
        [cell setObject:object];
        
        return cell;
        
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger tableTag = tableView.tag;
    
    NSArray *dataSource = self.allTableDataSource[[self getDataSourceKey:tableView.tag]];
    
    /*若要复用此控件 则让数据源中的object 继承WSOrgBean即可*/
    WSOrgBean *orgBean = dataSource[indexPath.row];

    if (tableTag != K_TABLE_BASE_TAG + self.maxNum  - 1) {

        [self updateChildLevelDataWith:orgBean tag:tableTag];
    }
}


- (void)updateParentLevelDataWith:(WSOrgBean *)currentOrgBean  parentOrgBean:(WSOrgBean *)pOrgBean tag:(NSInteger)currentTableTag{
    
    if (pOrgBean ) {
        
        NSInteger  parentTableTag = currentTableTag - 1;
        
        if (![pOrgBean.selectedChildren containsObject:currentOrgBean]) {
            [pOrgBean.selectedChildren addObject:currentOrgBean];
        }else {
            [pOrgBean.selectedChildren removeObject:currentOrgBean];
        }
        
        UITableView *parentTable = [self viewWithTag:parentTableTag];
        
        [parentTable reloadData];
        
        if (pOrgBean) {
            [self updateParentLevelDataWith:currentOrgBean parentOrgBean:pOrgBean.parentOrgBean tag:parentTableTag];
        }
    }
}


- (void)updateChildLevelDataWith:(WSOrgBean *)orgBean  tag:(NSInteger )tableTag{
    
    
    if ([[orgBean getChildren] count] > 0) {
        NSMutableArray *children = [orgBean getChildren];
        
        NSInteger  childrenTableTag = tableTag + 1;
        
        NSString *key = [self getDataSourceKey:childrenTableTag];
        
        self.allTableDataSource[key] = children;
        
        UITableView *childrenTable = [self viewWithTag:childrenTableTag];
        
        [childrenTable reloadData];
    }else {
        [self clearTableDataWith:tableTag];
    }
}


- (void)clearTableDataWith:(NSInteger) tag {
    if (tag < self.maxNum + K_TABLE_BASE_TAG) {
        NSInteger childTag = tag + 1;
        NSString * key = [self getDataSourceKey:childTag];
        self.allTableDataSource[key] = [@[] mutableCopy];
        UITableView *chilrenTable = [self viewWithTag:childTag];
        [chilrenTable reloadData];
        [self clearTableDataWith:childTag];
    }
}


- (NSString *)getDataSourceKey:(NSInteger)tableTag {
    
    return [NSString stringWithFormat:@"%@_%ld",DATASOURCE_PREFIX_KEY,(long)tableTag];
}

- (NSMutableAttributedString *)text:(NSString *)text addSpecialColor:(UIColor *)color  inRange:(NSRange)range {
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    return str;
}


#pragma mark WSTileListChildrenTableViewCellDelegate Method

- (void)tableViewCell:(WSTileListChildrenTableViewCell *)cell didSelectOrgBean:(WSOrgBean *)orgBean tag:(NSInteger)tableTag {
    
    if (orgBean.status) {
        [self.choseOrgs addObject:orgBean];
    }else {
        [self.choseOrgs removeObject:orgBean];
    }
    
    NSRange range = [self.totalLabel.text rangeOfString:@"("];
    _totalLabel.textColor = [UIColor grayColor];
    NSString *text = [NSString stringWithFormat:@"已选择组织数(%lu)",(unsigned long)[self.choseOrgs count]];
    NSMutableAttributedString *str = [self text:text addSpecialColor:K_MAIN_TINIT_COLOR inRange:NSMakeRange(range.location, range.length + 2)];
    _totalLabel.attributedText = str;
   
    if (orgBean.parentOrgBean) {
        [self updateParentLevelDataWith:orgBean parentOrgBean:orgBean.parentOrgBean tag:tableTag];

    }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
