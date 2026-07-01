//
//  WSSearchTagGroupView.m
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSearchTagGroupView.h"
#import "WSSearchTagView.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseEmployeTable.h"

#define kLabelLeftSpace 15
#define kLabelHeight 30
#define kSearchTagViewHeight 40

#define kSearchTagViewTopSpace 10
#define kSearchTagViewLeftSpace 15
#define kSearchTagViewRightSpace 15
#define kSearchTagViewVerticalGap 12
#define kSearchTagViewHorizontalGap 12

typedef NS_ENUM(NSInteger, WSSearchTagGroupViewSelectMode) {
    WSSearchTagGroupViewSelectModeSingle,
    WSSearchTagGroupViewSelectModeMultiple,
};

@interface WSSearchTagGroupView () <WSSearchTagViewDelegate>

@property (nonatomic, assign) WSSearchTagGroupViewSelectMode selectMode;

@property (nonatomic, strong) NSMutableArray *searchTagViewArray;

@property (nonatomic, strong) NSMutableArray *selectedSearchTagViewArray;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation WSSearchTagGroupView

- (instancetype)initWithFrame:(CGRect)frame qstBean:(WSAcvtBean_qst *)qstBean
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _qstBean = qstBean;
        
        _selectedTagArray = [NSMutableArray array];
        _selectedSearchTagViewArray = [NSMutableArray array];
        
        if ([_qstBean.qstType isEqualToString:@"R"] || [_qstBean.qstType isEqualToString:@"SS"] || [_qstBean.qstType isEqualToString:@"RD"]) {
            _selectMode = WSSearchTagGroupViewSelectModeSingle;
        }else {
            _selectMode = WSSearchTagGroupViewSelectModeMultiple;
        }
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelLeftSpace, 0, self.width - kLabelLeftSpace, kLabelHeight)];
        [titleLabel setText:qstBean.qstName];
        [titleLabel setTextColor:[UIColor grayColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 15 : 17]];
        [titleLabel setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        NSArray *searchTagArray =  nil;
        if ([_qstBean.qstType isEqualToString:@"R"] || [_qstBean.qstType isEqualToString:@"SS"]) {
            searchTagArray = [qstBean.opt valueForKeyPath:@"@unionOfObjects.optName"];
        }else if ([_qstBean.qstType isEqualToString:@"RD"]) {
            NSArray *dicts;
            if ([_qstBean.ds isEqualToString:@"dicts"]) {
                WSBaseDictsDBService *baseDictsDBService = [[WSBaseDictsDBService alloc] init];
                dicts = [baseDictsDBService queryDictWithType:_qstBean.filter];
            }else if ([_qstBean.ds isEqualToString:@"emp"]){
                 dicts = [[WSBaseEmployeTable sharedTable] queryWithType:_qstBean.ds];
            }
            
            searchTagArray = [dicts valueForKeyPath:@"@unionOfObjects.name"];

        }
        
        [self addSearchTagViews:searchTagArray];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame searchTagString:(NSString *)searchTagString
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _searchTagString = searchTagString;
        _selectMode = WSSearchTagGroupViewSelectModeMultiple;
        
        NSArray *searchTagArray = [searchTagString componentsSeparatedByString:@"@"];
        [self addSearchTagViews:searchTagArray];
    }
    
    return self;
}

- (void)addSearchTagViews:(NSArray *)searchTagArray
{
    self.searchTagViewArray = [NSMutableArray arrayWithCapacity:[searchTagArray count]];
    
//    CGFloat x = kSearchTagViewLeftSpace;
//    CGFloat y = self.titleLabel ? self.titleLabel.bottom : 0;
    
    CGFloat x = kSearchTagViewLeftSpace;
    CGFloat y = (self.titleLabel ? self.titleLabel.bottom : 0) + kSearchTagViewTopSpace;
    
    CGFloat width = (self.width - 2 * kSearchTagViewLeftSpace - 2 * kSearchTagViewHorizontalGap)/3;
    
    for(NSString *searchTag in searchTagArray) {
        
        WSSearchTagView *tagView = [[WSSearchTagView alloc] initWithFrame:CGRectMake(x, y, width, kSearchTagViewHeight) searchTag:searchTag];
        tagView.delegate = self;
        [self addSubview:tagView];
        [self.searchTagViewArray addObject:tagView];
        
//        if (x + tagView.width + kSearchTagViewRightSpace > self.width) {
//            y += kSearchTagViewVerticalGap + kSearchTagViewHeight;
//            x = kSearchTagViewLeftSpace;
//            tagView.frame = CGRectMake(x, y, tagView.width, tagView.height);
//            x += tagView.width + kSearchTagViewHorizontalGap;
//        }else {
//            x += tagView.width + kSearchTagViewHorizontalGap;
//        }
        
        if (x + tagView.width + kSearchTagViewRightSpace > self.width) {
            y += kSearchTagViewVerticalGap + kSearchTagViewHeight;
            x = kSearchTagViewLeftSpace;
            tagView.frame = CGRectMake(x, y, tagView.width, tagView.height);
            x += tagView.width + kSearchTagViewHorizontalGap;
        }else {
            x += tagView.width + kSearchTagViewHorizontalGap;
        }
    }
    
    CGRect frame = self.frame;
    frame.size.height = y + kSearchTagViewVerticalGap + kSearchTagViewHeight;
    self.frame = frame;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kLabelLeftSpace, self.height - 1, self.width - kLabelLeftSpace, 1)];
    [line setBackgroundColor:RGBCOLOR(232, 232, 232)];
    [self addSubview:line];
}

- (void)resetAllTags
{
    for (WSSearchTagView *tagView in _selectedSearchTagViewArray) {
        [tagView setSelected:NO];
    }
    
    [_selectedSearchTagViewArray removeAllObjects];
    [_selectedTagArray removeAllObjects];
}

- (void)setSelectedTagArray:(NSMutableArray *)selectedTagArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (WSSearchTagView *tagView in self.searchTagViewArray) {
        if ([selectedTagArray containsObject:tagView.searchTag]) {
            [_selectedSearchTagViewArray addObject:tagView];
            [array addObject:tagView.searchTag];
            [tagView setSelected:YES];
        }
    }
    
    _selectedTagArray = array;
}

#pragma mark - WSSearchTagViewDelegate

- (void)selectChanged:(WSSearchTagView *)searchTagView
{
    if (searchTagView.selected) {
        
        if (self.selectMode == WSSearchTagGroupViewSelectModeSingle) {
            [self resetAllTags];
        }
        
        [_selectedSearchTagViewArray addObject:searchTagView];
        [_selectedTagArray addObject:searchTagView.searchTag];
    }else {
        [_selectedSearchTagViewArray removeObject:searchTagView];
        [_selectedTagArray removeObject:searchTagView.searchTag];
    }
}

@end
