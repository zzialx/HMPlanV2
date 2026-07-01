//
//  WSMutiserieTableView.m
//  WinSFA
//
//  Created by winchannel on 16/8/19.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMutiserieTableView.h"
#import "WSAppData.h"
#import "WSVisitStorePlanTable.h"

@interface WSMutiserieTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *departmentArray;
@property (nonatomic,strong) WSStoreBean *currentStore;
@property (nonatomic,strong) NSArray *showDoctors;
@property (nonatomic,strong) UILabel *coutLabel;
@property (nonatomic,strong)NSString *sleectDate;
@property (nonatomic,strong)NSString *filter;

@end

@implementation WSMutiserieTableView

- (id)initWithFrame:(CGRect)frame
   withCurrentStore:(WSStoreBean *)aStore
    withCurrentDate:(NSString *)currentDate
         withFilter:(NSString *)filter{
    
    self = [super initWithFrame:frame];
    if (self) {
        _currentStore = aStore;
        self.backgroundColor = [UIColor whiteColor];
        _doctorArray = [[NSMutableArray alloc]init];
        _departmentArray = [[NSArray alloc]init];
        _allSelectedDoctors = [[NSMutableArray alloc]init];
        _sleectDate = currentDate;
        _filter = filter;
        [self initData];
    }
    return self;
    
}

- (void)setSubViews{
    
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    label.text =[NSString stringWithFormat:@"当前计划拜访医生总数     0"];
    label.backgroundColor = [UIColor colorWithRed:0.45f green:0.82f blue:0.98f alpha:1.00f];
    label.textColor =[UIColor whiteColor];
    self.coutLabel = label;
    [self addSubview:label];
    
    UITableView *departmentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, self.bounds.size.width/2.0, self.bounds.size.height -40) style:UITableViewStylePlain];
    departmentTableView.dataSource = self;
    departmentTableView.delegate = self;
    departmentTableView.tag = 10001;
    departmentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    departmentTableView.backgroundColor =[UIColor whiteColor];
    self.dePartmentTableView = departmentTableView;
    [self addSubview:departmentTableView];
    
    UITableView *doctorsTableView = [[UITableView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2.0, 40, self.bounds.size.width/2.0, self.bounds.size.height -40) style:UITableViewStylePlain];
    doctorsTableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    doctorsTableView.dataSource = self;
    doctorsTableView.delegate = self;
    doctorsTableView.tag = 10002;
    doctorsTableView.backgroundColor = [UIColor whiteColor];
    self.doctorTableView = doctorsTableView;
    
    [self addSubview:doctorsTableView];
}

- (void)reloadSubViews{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //默认选中UITableView第一行
    
    if (self.departmentArray.count >0) {
        [self.dePartmentTableView touchRowAtIndexPath:indexPath animated:YES];
        [self.dePartmentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.doctorTableView reloadData];
    }
    
}
- (void)initData{
    
    
    if (self.doctorArray.count >0) {
        [self.doctorArray removeAllObjects];
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    WSInPlanStoreBean *inplanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
    WSOutPlanStoreBean *outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
    
    [dataArray addObjectsFromArray:inplanStoreArray.storesArray];
    [dataArray addObjectsFromArray:outPlanStoreArray.storesArray];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pid == %@",self.currentStore.Id];
    NSArray *array = [[dataArray filteredArrayUsingPredicate:predicate] mutableCopy];
    
    
    //已拜访计划的门店ID
    NSArray *array2 = [[WSVisitStorePlanTable sharedTable]queryVisitStorePlanByDate:self.sleectDate];
    NSArray *storeidsArray = [[NSArray alloc]init];
    if(array2 && array2.count>0){
        storeidsArray=[[[array2 objectAtIndex:0] storeids] componentsSeparatedByString:@","];
        
    }
    
    NSMutableArray *doctores = [NSMutableArray array];
    for (WSStoreBean *store in array) {
        WSStoreBean *store_copy = [store copy];
        for (NSString *storeId in storeidsArray) {
            if ([store.Id isEqualToString:storeId]) {
                store_copy.bPlanned = YES;
                [self.allSelectedDoctors addObject:store_copy];
               
            }
        }
        [doctores addObject:store_copy];
        
    }
    if (self.filter) {
        NSPredicate *filterPredicate =[NSPredicate predicateWithFormat:@"self.styp == %@",self.filter];
        NSArray *filtersDs = [doctores filteredArrayUsingPredicate:filterPredicate];
        [self.doctorArray addObjectsFromArray:filtersDs];
    }else{
        
        [self.doctorArray addObjectsFromArray:doctores];
    }
    _departmentArray = [self.doctorArray valueForKeyPath:@"@distinctUnionOfObjects.item_name"];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger rowCount = 0;
    if (tableView.tag == 10001) {
        rowCount = self.departmentArray.count;
    }else if (tableView.tag == 10002){
        rowCount = self.showDoctors.count;
        
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *departmentCellIdentifier = @"departmentCellIdentifier";
    static NSString *doctorCellIdentifier = @"doctorCellIdentifier";
    
    if (tableView.tag == 10001) {
        
        UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:departmentCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:departmentCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.text = nil;
        //部门名称
        NSString *departmentName = [self.departmentArray objectAtIndex:indexPath.row];
        NSPredicate *subPredicate = nil;
        if (self.filter && self.filter.length >0) {
            subPredicate = [NSPredicate predicateWithFormat:@"self.item_name == %@ and self.styp == %@",departmentName,self.filter];
        }else{
            subPredicate = [NSPredicate predicateWithFormat:@"self.item_name == %@",departmentName];
        }

        //下属已拜访门店
        NSArray *subVisitedStores =[self.allSelectedDoctors filteredArrayUsingPredicate:subPredicate];
        //下属门店
        NSArray *subStores =[self.doctorArray filteredArrayUsingPredicate:subPredicate];
        cell.textLabel.text = departmentName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)subVisitedStores.count,(unsigned long)subStores.count];
   
        
        return cell;

    }else if (tableView.tag == 10002){
        UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:doctorCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doctorCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.accessoryView = nil;
        cell.textLabel.text = nil;
        
        
        WSStoreBean *indexStore = [self.showDoctors objectAtIndex:indexPath.row];

        cell.textLabel.text = indexStore.name;
        
        if (indexStore.bPlanned) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_true.png"]];
        }
        else{
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_false.png"]];
        }
        
        return cell;
    }
    return nil;
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 10001) {
        
        self.selectedDepartmentIndex = indexPath.row;
        
        NSString *departmentName = [self.departmentArray objectAtIndex:indexPath.row];
        NSPredicate *subPredicate = nil;
        if (self.filter && self.filter.length >0) {
            subPredicate = [NSPredicate predicateWithFormat:@"self.item_name == %@ and self.styp == %@",departmentName,self.filter];
        }else{
            subPredicate = [NSPredicate predicateWithFormat:@"self.item_name == %@",departmentName];
        }
        self.showDoctors = nil;
        self.showDoctors  =[self.doctorArray  filteredArrayUsingPredicate:subPredicate];
        [self.doctorTableView reloadData];
        
    }else if (tableView.tag == 10002){
        
        WSStoreBean *sb = [self.showDoctors objectAtIndex:indexPath.row];
        
        for (WSStoreBean *storebean in self.doctorArray) {
            if ([storebean.Id isEqualToString:sb.Id]) {
                sb.bPlanned = !sb.bPlanned;
            }
            if (storebean.bPlanned && ![self.allSelectedDoctors containsObject:storebean]) {
                [self.allSelectedDoctors addObject:storebean];
               
            }else if (!storebean.bPlanned && [self.allSelectedDoctors containsObject:storebean]){
                [self.allSelectedDoctors removeObject:storebean];
            }
        }
        [self.doctorTableView reloadData];
        [self.dePartmentTableView reloadData];
    }
    //显示当前医院拜访计划设置人数
    NSString *count = nil;
    if (self.filter && self.filter.length >0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.styp == %@",self.filter];
        NSArray *filterDoctors = [self.allSelectedDoctors filteredArrayUsingPredicate:predicate];
        count= [NSString stringWithFormat:@"当前计划拜访医生总数     %lu",(unsigned long)filterDoctors.count];
        [self.coutLabel setText:count];
    }
    else{
        count= [NSString stringWithFormat:@"当前计划拜访医生总数     %lu",(unsigned long)self.allSelectedDoctors.count];
        [self.coutLabel setText:count];
    }
}

@end
