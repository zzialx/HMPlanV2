//
//  WSTileListPannel.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTileListPannel.h"

#import "I_W_DataSource.h"

#import "I_W_BuildInfo.h"

#import "WSTileListContentView.h"

#import "WSDataSourceFromOrg.h"

#import "I_W_DisplayValue.h"

#import "WSOrgBean.h"

#define K_SHOW_TL_BUTTON_WIDTH  44

#define K_SHOW_TL_BUTTON_HEIGHT 44

#define K_SHOW_TEXTVIEW_HEIGHT 50

#define K_SHOW_TEXTVIEW_WIDTH 750



@interface WSTileListPannel()

@property (nonatomic,strong)UIButton *showTileListBtn;

@property (nonatomic,strong)WSTileListContentView *listContentView;

@property (nonatomic,assign)CGRect rect;

@property (nonatomic,assign) NSInteger tableCount;

@property (nonatomic,strong) NSMutableArray *redisOrgs;

@property (nonatomic,strong) __block NSMutableArray *selectedOrgs;

@property (nonatomic,strong) UILabel *showTextLabel;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,assign) CGFloat originHeight;

@end

@implementation WSTileListPannel



-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
    
        _redisOrgs = [[NSMutableArray alloc] init];
        _selectedOrgs = [[NSMutableArray alloc] init];
        _dataSource = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

- (void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    [xdataSource getDataSourceFor:xbuildInfo];
    
    self.dataSource = [NSMutableArray arrayWithArray:xdataSource.dataSourceArray];
    
    [self clearDataSourceOldStatus:self.dataSource];
    
    NSString  *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
   
    [self tidyupDataSource:self.dataSource selectedOrgs:displayValue];
    
    if ([xdataSource isKindOfClass:[WSDataSourceFromOrg class]]) {
        _tableCount = [(WSDataSourceFromOrg *)xdataSource orgLevels];
    }
   
   
    
    CGFloat maxHeigh = MAX(K_SHOW_TL_BUTTON_HEIGHT,K_SHOW_TEXTVIEW_HEIGHT);
    
    CGFloat y = (self.height -maxHeigh)/2;
    
    CGFloat height = self.height;
    
    if (height < maxHeigh) {
        height = maxHeigh + 2 * 5;
        y = 5.0f;
        self.height = height;
    }
    
    _originHeight = height;

    NSArray *orgNames = [self.redisOrgs valueForKey:@"name"];
    NSString *redisOrgStr = [orgNames componentsJoinedByString:@","];
    _showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.origin.x + self.titleLabel.width + 60, (self.height - K_SHOW_TEXTVIEW_HEIGHT)/2, K_SHOW_TEXTVIEW_WIDTH, K_SHOW_TEXTVIEW_HEIGHT)];
    _showTextLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
    _showTextLabel.textAlignment = NSTextAlignmentLeft;
    _showTextLabel.userInteractionEnabled = NO;
    _showTextLabel.numberOfLines = 0;
    _showTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _showTextLabel.text = redisOrgStr;
    [self addSubview:self.showTextLabel];
    
     _showTileListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_showTileListBtn addTarget:self action:@selector(showTileList:) forControlEvents:UIControlEventTouchUpInside];
    [_showTileListBtn setFrame:CGRectMake(self.width - K_SHOW_TL_BUTTON_WIDTH ,(self.height - K_SHOW_TL_BUTTON_HEIGHT)/2,K_SHOW_TL_BUTTON_WIDTH, K_SHOW_TL_BUTTON_HEIGHT)];
    [_showTileListBtn setImage:[UIImage imageForName:@"showTile"] forState:UIControlStateNormal];
    [self addSubview:_showTileListBtn];
    
    CGRect rect = self.frame;
    [self setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height)];
    
}

#pragma mark Button  Click Method

- (void)showTileList:(UIButton *)button {
    
    
    _rect = [[UIScreen mainScreen] bounds];
    
    if (_listContentView == nil) {
        
        _listContentView = [[WSTileListContentView alloc] initWithFrame:CGRectMake(0, _rect.size.height,_rect.size.width
                                                                                   , _rect.size.height)];
        _listContentView.backgroundColor = [UIColor whiteColor];
        
        __weak typeof (self) wself = self;
        _listContentView.tileClickBlock = ^ (NSInteger tag,NSArray *selectedOrgs) {
            
            __strong typeof (wself) sself = wself;
            if (tag == 333) {
                
            }else if (tag == 334) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", sself.selectedOrgs];
                NSArray *newOrgs = [selectedOrgs filteredArrayUsingPredicate:predicate];
                [sself.selectedOrgs addObjectsFromArray:newOrgs];
                NSArray *orgNames = [sself.selectedOrgs valueForKey:@"name"];
                NSString *redisOrgStr = [orgNames componentsJoinedByString:@","];
                sself.showTextLabel.text = redisOrgStr;
                
                CGSize newSize = [redisOrgStr ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font - 2] constrainedToWidth:K_SHOW_TEXTVIEW_WIDTH lineBreakMode:NSLineBreakByCharWrapping];
                
                if (newSize.height > K_SHOW_TEXTVIEW_HEIGHT) {
                    CGFloat   offset_y = newSize.height - K_SHOW_TEXTVIEW_HEIGHT + 5.0f;
                    sself.showTextLabel.size = CGSizeMake(sself.showTextLabel.size.width, newSize.height);
            
                    CGRect rect = sself.frame;
                    sself.frame = CGRectMake(rect.origin.x, rect.origin.y, K_SHOW_TEXTVIEW_WIDTH, rect.size.height + offset_y );
                } else if (newSize.height < K_SHOW_TEXTVIEW_HEIGHT) {
                    
                    sself.showTextLabel.size = CGSizeMake(sself.showTextLabel.size.width, K_SHOW_TEXTVIEW_HEIGHT);
                    
                    CGRect rect = sself.frame;
                    sself.frame = CGRectMake(rect.origin.x, rect.origin.y, K_SHOW_TEXTVIEW_WIDTH, sself.originHeight);
                    
                }
                
            }
            
            [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                sself.listContentView.centerY = -_rect.size.height/2;
            } completion:nil];
        };
        
        
        
        [self.listContentView setDataSource:self.dataSource redisOrgs:self.redisOrgs];
        
        [_listContentView loadSubViewsAndTableNum: self.tableCount qstName:[xbuildInfo getQuestName]];
        
        [[self superview].window addSubview:_listContentView];
    }

    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _listContentView.centerY = _rect.size.height/2;
    } completion:nil];
}


- (void)clearDataSourceOldStatus:(NSMutableArray *)dataSource {
    
    for (WSOrgBean *org in dataSource) {
        [self clearOrgStatus:org];
    }
}

- (void)clearOrgStatus:(WSOrgBean *)orgBean {
    orgBean.status = NO;
    if ([orgBean.childen count] > 0) {
        [orgBean.selectedChildren removeAllObjects];
    }
    
    for (WSOrgBean *subOrgBean  in orgBean.childen) {
        [subOrgBean.selectedChildren removeAllObjects];
        subOrgBean.status = NO;
        [self clearOrgStatus:subOrgBean];
    }
}


- (NSMutableArray *)tidyupDataSource:(NSMutableArray *)dataSource  selectedOrgs:(NSString *)orgStrs {
    
    NSArray *orgs = [orgStrs componentsSeparatedByString:@","];
    
    for (WSOrgBean *orgBean  in dataSource) {
        
        [self orgBean:orgBean selectedOrgs:orgs];
    }
    
    self.selectedOrgs = self.redisOrgs;
    
    return dataSource;
}

- (void)orgBean:(WSOrgBean *)orgBean selectedOrgs:(NSArray *)orgs {
    
    if ([orgs containsObject:orgBean.orgId]) {
        
        if (![self.redisOrgs containsObject:orgBean]) {
            [self.redisOrgs addObject:orgBean];
        }
        orgBean.status = YES;
    }
    for (WSOrgBean *subOrg in orgBean.childen) {
        
        if ([orgs containsObject:subOrg.orgId]) {
            
            if (![self.redisOrgs containsObject:subOrg]) {
                [self.redisOrgs addObject:subOrg];
            }
            
            [orgBean.selectedChildren addObject:subOrg];
            
            [orgBean.parentOrgBean.selectedChildren addObject:subOrg];
            
            [self orgBean:subOrg selectedOrgs:orgs];
        }
    }
}


- (void)widgetDidLoadFinish
{
    /* YIHAIKERRY-3084 问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    */
}


-(NSObject *)getResultDirectly{
    
    NSArray *orgIds = [self.selectedOrgs  valueForKeyPath:@"@distinctUnionOfObjects.orgId"];
    
    return [orgIds componentsJoinedByString:@","];
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value{
    
    
}

-(void)loadValidator:(NSObject<I_W_Validate> *)validateobjin{
    
    [super loadValidator:validateobjin];
    
}


- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.titleLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        [self.showTileListBtn setUserInteractionEnabled:NO];
    }else {
        self.titleLabel.textColor = DETAIL_TEXT_COLOR;
        [self.showTileListBtn setUserInteractionEnabled:YES];
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
