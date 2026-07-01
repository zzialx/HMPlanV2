//
//  WSVisitRecordDetailController.m
//  WinSFA
//
//  Created by Nemo on 14-3-25.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitRecordDetailController.h"
#import "WSVisitRecordAcvt.h"

@interface WSVisitRecordDetailController ()
{
    NSMutableArray *details;
    UIScrollView   *scrollView;
}

@end

@implementation WSVisitRecordDetailController


/**
 * 根据detailArray初始化
 */
- (id)initWithDetailString:(NSArray*)detailArray
{
    self = [super init];
    if (self)
    {
        [self fillDetals:detailArray];
    }
    return self;
}

/**
 * 根据array(元素为dic)来构造details(元素为WSVisitRecordDetail)
 */
- (void)fillDetals:(NSArray*)array
{
    if (!array) {        return;    }
    if(array.count < 1){    return; }
    
    if (details) {
        [details removeAllObjects];
    }
    if (!details) {
        details = [[NSMutableArray alloc] initWithCapacity:array.count];
    }
    
    for (NSDictionary *dic in array)
    {
        WSVisitRecordAcvt *visitDetail = [[WSVisitRecordAcvt alloc] init];
        [visitDetail fillByDic:dic];
        [details addObject:visitDetail];
    }
}


- (void)loadView
{
    [super loadView];
    scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setShowsVerticalScrollIndicator:YES];
    [[self view] addSubview:scrollView];
    
    CGFloat currentY = 10.0;   // 当前的高度
    
    CGFloat acvtGap = 20;    // acvt间隔
    CGFloat qstGap = 5.0;     // qst间隔
    
    CGFloat acvtNameHeight = 40;
    CGFloat qstNameHeight = 40;
    
    for (WSVisitRecordAcvt *visitDetail in details)
    {
        // acvt name
        UILabel *acvtNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, currentY, [UIScreen mainScreen].bounds.size.width - 10, acvtNameHeight)];
        [acvtNameLabel setText:visitDetail.acvtName];
        [acvtNameLabel setBackgroundColor:[UIColor whiteColor]];
        [scrollView addSubview:acvtNameLabel];
        
        currentY = currentY  + acvtNameHeight;
        
        for (NSDictionary *dic in visitDetail.qstArray)
        {
            // qst name
            UILabel *qstLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, currentY, [UIScreen mainScreen].bounds.size.width - 40, qstNameHeight)];
            NSString *qstName = [dic objectForKey:@"qstname"];
            NSRange r1 = [qstName rangeOfString:@":"];
            NSRange r2 = [qstName rangeOfString:@"："];
            if (r1.location == NSNotFound && r2.location == NSNotFound)
            {
                qstName = [qstName stringByAppendingString:@":"];
            }
            [qstLabel setText:[NSString stringWithFormat:@"%@ %@",qstName,[dic objectForKey:@"val"]]];
            [qstLabel setBackgroundColor:[UIColor whiteColor]];
            [scrollView addSubview:qstLabel];
            
            currentY = currentY + qstGap + qstNameHeight;
        }
        
        currentY = currentY + acvtGap;
    }
    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, currentY + qstNameHeight)];
}






























@end
