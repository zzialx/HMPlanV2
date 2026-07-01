//
//  WSActionListView.m
//  WinSFA
//
//  Created by yang on 17/1/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSActionListView.h"

#define kAnimationDuration 0.3
#define kCellHeight 44.0f
#define kBackgroundColor RGBCOLOR(62, 64, 65)

@interface WSActionListView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dictInfoArray;

@property (nonatomic, weak) id target;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *blockView;

@property (nonatomic, assign) CGPoint showPoint;

@property (nonatomic, assign) CGSize originSize;

@end

@implementation WSActionListView

- (instancetype)initWithFrame:(CGRect)frame actionDicInfoList:(NSArray *)dicInfoArray target:(id)target
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kBackgroundColor;
        
        _dictInfoArray = dicInfoArray;
        _target = target;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = kBackgroundColor;
        self.tableView = tableView;
        [self addSubview:tableView];
        
        self.frame = CGRectMake(0, 0, frame.size.width, kCellHeight * [dicInfoArray count]);
        
        self.originSize = CGSizeMake(frame.size.width, kCellHeight * [dicInfoArray count]);
    }
    return self;
}


- (void)showOnView:(UIView *)view fromPoint:(CGPoint)point
{
    [self.tableView reloadData];
    
    self.showPoint = point;
    
    self.blockView = [[UIView alloc] initWithFrame:view.bounds];
    self.blockView.backgroundColor = [UIColor clearColor];
//    self.blockView.alpha = 0.01;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blockViewTapped:)];
    [self.blockView addGestureRecognizer:tap];
    [view addSubview:self.blockView];
    
    CGRect endFrame;
    
    if (point.x + self.originSize.width > view.width) {
        endFrame = CGRectMake(point.x - self.originSize.width, point.y, self.originSize.width, self.originSize.height);
    }else {
        endFrame = CGRectMake(point.x, point.y, self.originSize.width, self.originSize.height);
    }
    
    self.frame = CGRectMake(point.x, point.y, 0, 0);
    
    [view addSubview:self];
    
    self.alpha = 1.0;
    
    if (IOS7_OR_LATER) {
        [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = endFrame;
            self.blockView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.frame = endFrame;
            self.blockView.alpha = 1.0;
        }];
    }
}

- (void)blockViewTapped:(id) sender
{
    [self hideView];
}

- (void)hideView
{
    [self.blockView removeFromSuperview];
    
    if (IOS7_OR_LATER) {
        [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = CGRectMake(self.showPoint.x, self.showPoint.y, 10, 10);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.frame = CGRectMake(self.showPoint.x, self.showPoint.y, 10, 10);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dictInfoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifer = @"actionListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
        cell.backgroundColor = RGBCOLOR(62, 64, 65);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    NSDictionary *dic = self.dictInfoArray[indexPath.row];
    
    cell.textLabel.text = dic[kActionInfoDicTitleKey];
    cell.imageView.image = [UIImage scaledImageForName:dic[kActionInfoDicImageKey] ofType:@"png"];
    

    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = RGBCOLOR(45, 46, 47);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.dictInfoArray[indexPath.row];
    NSString *methodName = dic[kActionInfoDicSelectorKey];
    SEL selector = NSSelectorFromString(methodName);
    
    if ([self.target respondsToSelector:selector]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:selector];
#pragma clang diagnostic pop
    }
    
    [self hideView];
}

@end
