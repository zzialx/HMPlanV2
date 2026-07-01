//
//  CalendarView.m
//  日历
//
//  Created by zhiqing on 16/7/21.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import "WSCalendarView.h"
#import "WSDatePicker.h"
#import "PureLayout.h"
#import "WSCalendarModel.h"
#import "WSCollectionViewCell.h"
#import "WSSelectTimeView.h"
@interface WSCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WSSelectTimeViewDelegate>

@property(nonatomic,strong) NSCalendar * calendar;
@property(nonatomic,strong) WSSelectTimeView *mounthBtn; // 选择月份的
@property(nonatomic,strong) UIImageView *leftBtn;   // 上一周
@property(nonatomic,strong) UIImageView *rightBtn;  // 下一周
@property(nonatomic,strong) UICollectionView *midCollectionView; // 中间显示周日到周六的视图
@property(nonatomic,strong) NSArray *weekArray;
@property(nonatomic,strong) NSArray *weekDataArray; // 每次装的7个数据模型
@property(nonatomic,strong) NSDate *currentDate;

@end

@implementation WSCalendarView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
     [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{

    self.weekArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    self.mounthBtn = [[WSSelectTimeView alloc]init];
    _mounthBtn.style = WSSelectTimeViewStyleYMD;
    self.mounthBtn.selectTime = date;
    self.mounthBtn.delegate = self;
    [self addSubview:self.mounthBtn];
    [self.mounthBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [self.mounthBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [self.mounthBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.2];
    [self.mounthBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:7];
    
    self.leftBtn = [UIImageView newAutoLayoutView];
    self.leftBtn.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *leftBtnImage = [[UIImage imageNamed:@"icon_rili_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBtn.tintColor = MAIN_TINT_COLOR;
    
    self.leftBtn.image = leftBtnImage;
    UITapGestureRecognizer * gestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getlastWeekData)];
    [self.leftBtn addGestureRecognizer:gestureRecognize];
    self.leftBtn.userInteractionEnabled = YES;
    [self addSubview:self.leftBtn];
    
    [self.leftBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.mounthBtn withOffset:10];
    [self.leftBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.05];
    [self.leftBtn autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.mounthBtn withOffset:-8];
    [self.leftBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.mounthBtn withOffset:-2];
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.midCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
   
    self.midCollectionView.backgroundColor =  [UIColor clearColor];
    
    
    [self addSubview:self.midCollectionView];
    [self.midCollectionView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.leftBtn withOffset:-1];
    [self.midCollectionView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.65];
    [self.midCollectionView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.mounthBtn withOffset:-1];

    [self.midCollectionView registerClass:[WSCollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    self.midCollectionView.delegate = self;
    self.midCollectionView.dataSource = self;
    UIImage * image = [UIImage imageNamed:@"riqi_bj@2x"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
    UIView * view = [[UIView alloc]init];
    [view addSubview:imageView];

    self.midCollectionView.backgroundView = view;
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:3];

    [imageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.midCollectionView withOffset:-8];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];

    
    
    self.rightBtn = [UIImageView newAutoLayoutView];
    self.rightBtn.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *rightBtnImage = [[UIImage imageNamed:@"icon_rili_next"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightBtn.tintColor = MAIN_TINT_COLOR;
    
    self.rightBtn.image = rightBtnImage;
    UITapGestureRecognizer * rightGestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getNextWeekData)];
    [self.rightBtn addGestureRecognizer:rightGestureRecognize];
    self.rightBtn.userInteractionEnabled = YES;
    [self addSubview:self.rightBtn];
    [self.rightBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.midCollectionView withOffset:-1];
    [self.rightBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.05];
    [self.rightBtn autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.mounthBtn withOffset:-8];
    [self.rightBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.mounthBtn withOffset:-2];
    [@[self.mounthBtn,self.midCollectionView] autoMatchViewsDimension:ALDimensionHeight];
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    [self.calendar setFirstWeekday:1];
    
    [self getDataWith:date];
    
}

-(void)getDataWith:(NSDate *)date{

    self.currentDate = date;
    self.weekDataArray =  [self getWeekOfFirstDayWithDate:date];
    [self.midCollectionView reloadData];
    
}
 // 获取传入日期当前周的数组
-(NSArray *)getWeekOfFirstDayWithDate:(NSDate *)date{

    NSInteger dateWeekNum = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    NSTimeInterval nowTime = [date timeIntervalSince1970]; // date的时间戳
    NSDate *needTimeDate = [NSDate dateWithTimeIntervalSince1970:nowTime - (dateWeekNum - 1)* 24*60*60]; // 根据传入的时间 该周 计算周日的时间

 
    NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:7];
    for (NSInteger i = 0; i < 7; i++) {
        WSCalendarModel * model = [[WSCalendarModel alloc]init];
        NSDate * tempDate = [needTimeDate dateByAddingTimeInterval:i * 24 * 60 * 60];
        if ([self.currentDate.description isEqualToString:tempDate.description]) {
            model.isSelected = YES;
        }
        model.week = self.weekArray[i];
        model.day = tempDate;
        [tempArray addObject:model];
    }
    return tempArray;
}

// 获取下周的数据
-(void)getNextWeekData{
    WSCalendarModel * model =  self.weekDataArray[6];
    NSDate * lastDate = model.day;
    self.weekDataArray = [self getWeekOfFirstDayWithDate:[lastDate dateByAddingTimeInterval:24 *60*60]];
    
    [self.midCollectionView reloadData];
}
// 获取上周的数据
-(void)getlastWeekData{
    WSCalendarModel * model =  self.weekDataArray[0];
    NSDate * lastDate = model.day;
    self.weekDataArray = [self getWeekOfFirstDayWithDate:[lastDate dateByAddingTimeInterval:-24 *60*60]];
    
    [self.midCollectionView reloadData];
}

#pragma -mark WSSelectTimeViewDelegate
-(void)selectTimeViewValueChanged:(NSDate *)date{
    
    [self getDataWith:date];
     // 这里需要加一个代理事件(可以做你选中日期之后需要做的事情:例如 筛选等)
    [self queryDataFromDBWithDate:date];
}

#pragma -mark   delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.weekDataArray.count;

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
     static NSString * reuserId = @"UICollectionViewCell";
    WSCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserId forIndexPath:indexPath];
    WSCalendarModel * model = self.weekDataArray[indexPath.row];

    cell.dateModel = model;
    
    return cell;

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(80, 30);
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (NSInteger i = 0; i< self.weekDataArray.count; i++) {
        WSCalendarModel *model = self.weekDataArray[i];
        if (i == indexPath.row) {
            model.isSelected = YES;
            self.mounthBtn.selectTime = model.day;
             // 这里需要加一个代理事件(可以做你选中日期之后需要做的事情:例如 筛选等)
            [self queryDataFromDBWithDate:model.day];
        }else{
            model.isSelected = NO;
        }
    }
    [collectionView reloadData];
   
   
}


// 查询数据的代理方法
-(void)queryDataFromDBWithDate:(NSDate *)date{
    
    if ([self.delegate respondsToSelector:@selector(queryDataFromDBByDate:)]) {
        [self.delegate queryDataFromDBByDate:date];
    }

}

#pragma mark - WSCalendarViewDelegate
-(void)queryDataFromDBByDate:(NSDate *)date {
    
}

@end
