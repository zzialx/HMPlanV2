//
//  CityPicker.m
//  CityPicker
//
//  Created by Jiepeng Zheng on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZJPAddressPickerView.h"
#import "SelectListControl.h"
#import "WSBaseDictsDBService.h"
#import "WSDictBean.h"

#define kCitys  @"citys"
#define kAreas  @"areas"

typedef NS_ENUM(NSInteger, DataSourceMode) {
    SelectListDataSourceFromCityDataFileMode,
    SelectListDataSourceFromDictsTableMode
};

@interface ZJPAddressPickerView ()

@property (nonatomic, strong) SelectListControl *prosl;
@property (nonatomic, strong) NSArray *pArray;

@property (nonatomic, strong) SelectListControl *citsl;
@property (nonatomic, strong) NSMutableArray *cArray;

@property (nonatomic, strong) SelectListControl *dicsl;
@property (nonatomic, strong) NSMutableArray *dArray;

@property (nonatomic, strong) NSDictionary *preInfoDic;
@property (nonatomic, assign) DataSourceMode selectListDataSourceMode;

@end

@implementation ZJPAddressPickerView

@synthesize pArray = _pArray;
@synthesize prosl = _prosl;

@synthesize citsl = _citsl;
@synthesize cArray = _cArray;

@synthesize dicsl = _dicsl;
@synthesize dArray = _dArray;

@synthesize streetTextField = _streetTextField;

@synthesize address = _address;
@synthesize codeAddress = _codeAddress;

#pragma mark - init & dealloc

// 用已填写的 dic 初始化
- (id)initWithFrame:(CGRect)frame withPreInfoDic:(NSDictionary *)preInfoDic {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.preInfoDic = [NSDictionary dictionaryWithDictionary:preInfoDic];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentLibraryFolderPath = [documentsDirectory stringByAppendingPathComponent:@"CityData"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentLibraryFolderPath])
        {
//            return nil;
        }
        

        
        NSArray *allCityDataArray = [NSArray arrayWithContentsOfFile:documentLibraryFolderPath];
        
        NSMutableArray *allCityDataMArray = [[NSMutableArray alloc] init];
        
        if (allCityDataArray.count > 0) {
            for (NSDictionary *cityDic in allCityDataArray) {
                if ([cityDic objectForKey:@"citys"] != nil) {
                    [allCityDataMArray addObject:cityDic];
                }
            }
        }
        
        self.pArray = allCityDataMArray;
        
        if (self.pArray.count > 0) {
            self.selectListDataSourceMode = SelectListDataSourceFromCityDataFileMode;
            
            // 回显省份的 id
            NSInteger provinceID = [[self.preInfoDic objectForKey:kProvinceID] integerValue];
            // 回显城市 id
            NSInteger cityID = [[self.preInfoDic objectForKey:kCityID] integerValue];
            // 回显区 id
            NSInteger areaID = [[self.preInfoDic objectForKey:kAreaID] integerValue];
            
            // 省份下拉列表index
            NSInteger proslIndex = 0;
            // 城市下拉列表index
            NSInteger citslIndex = 0;
            // 区下拉列表index
            NSInteger dicssIndex = 0;
            
            //        self.pArray = [NSArray arrayWithContentsOfFile:documentLibraryFolderPath];
            NSInteger pCount = [_pArray count];
            for (int i = 0; i < pCount; i++) {
                NSDictionary *dic = [_pArray objectAtIndex:i];
                NSInteger currentID = [[dic objectForKey:@"id"] integerValue];
                if (provinceID == currentID) {
                    proslIndex = i;
                    break;
                }
            }
            
            NSDictionary *firstPro = [_pArray objectAtIndex:proslIndex];
            NSArray *firstProCities = [firstPro objectForKey:kCitys];
            self.cArray = [NSMutableArray arrayWithArray:firstProCities];
            
            NSInteger cCount = [_cArray count];
            for (int i = 0; i < cCount; i++) {
                NSDictionary *dic = [_cArray objectAtIndex:i];
                NSInteger currentID = [[dic objectForKey:@"id"] integerValue];
                if (cityID == currentID) {
                    citslIndex = i;
                    break;
                }
            }
            
            NSDictionary *firstDic = [_cArray objectAtIndex:citslIndex];
            NSArray *firstCityDic = [firstDic objectForKey:kAreas];
            self.dArray = [NSMutableArray arrayWithArray:firstCityDic];
            
            NSInteger dCount = [_dArray count];
            for (int i = 0; i < dCount; i++) {
                NSDictionary *dic = [_dArray objectAtIndex:i];
                NSInteger currentID = [[dic objectForKey:@"id"] integerValue];
                if (areaID == currentID) {
                    dicssIndex = i;
                    break;
                }
            }
            CGFloat width = CGRectGetWidth(self.bounds);
            self.prosl = [[SelectListControl alloc] init];
            _prosl.selectListDelegate = self;
            _prosl.frame = CGRectMake(0, 0, width, 30);
            _prosl.content = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in _pArray)
            {
                NSString *pName = [dic objectForKey:@"name"];
                [_prosl.content addObject:pName];
            }
            _prosl.title = @"省";
            _prosl.selectedIndex = proslIndex;
            [self addSubview:_prosl];
            
            self.citsl = [[SelectListControl alloc] initWithFrame:CGRectMake(0, 40, width, 30)];
            _citsl.selectListDelegate = self;
            for (NSDictionary *dic in _cArray)
            {
                if (_citsl.content == nil)
                {
                    _citsl.content = [[NSMutableArray alloc] init];
                }
                NSString *cName = [dic objectForKey:@"name"];
                [_citsl.content addObject:cName];
            }
            _citsl.title = @"市";
            _citsl.selectedIndex = citslIndex;
            [self addSubview:_citsl];
            
            self.dicsl = [[SelectListControl alloc] initWithFrame:CGRectMake(0, 80, width, 30)];
            _dicsl.selectListDelegate = self;
            for (NSDictionary *dic in _dArray)
            {
                if (_dicsl.content == nil)
                {
                    _dicsl.content = [[NSMutableArray alloc] init];
                }
                NSString *cName = [dic objectForKey:@"name"];
                [_dicsl.content addObject:cName];
            }
            _dicsl.title = @"县";
            _dicsl.selectedIndex = dicssIndex;
            [self addSubview:_dicsl];
            
            // 如果街道的名字存在 则添加街道标题和需要输入内容的文本框
            NSString *streetName = [self.preInfoDic objectForKey:@"streetName"];
            if (streetName && [streetName isKindOfClass:[NSString class]]) {
                UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 60, 24)];
                label.text = @"街道:";
                label.backgroundColor = [UIColor clearColor];
                label.font = font;
                [self addSubview:label];
                
                self.streetTextField = [[UITextField alloc]initWithFrame:CGRectMake(50, 120, 260, 24)];
                _streetTextField.borderStyle = UITextBorderStyleRoundedRect;
                
                NSString *input = NSLocalizedString(@"please_fill_in", nil);
                _streetTextField.placeholder = input;
                _streetTextField.returnKeyType = UIReturnKeyDone;
                _streetTextField.font = font;
                _streetTextField.delegate = self;
                if (streetName) {
                    _streetTextField.text = streetName;
                }
                [self addSubview:_streetTextField];
            }
        }else{
            self.selectListDataSourceMode = SelectListDataSourceFromDictsTableMode;
            
            [self initDataSourceWithDictBeans];
        }
        

    }
    return self;
}

- (void)initDataSourceWithDictBeans
{
    // 回显省份的 id
    NSInteger provinceID = [[self.preInfoDic objectForKey:kProvinceID] integerValue];
    // 回显城市 id
    NSInteger cityID = [[self.preInfoDic objectForKey:kCityID] integerValue];
    // 回显区 id
    NSInteger areaID = [[self.preInfoDic objectForKey:kAreaID] integerValue];
    
    // 省份下拉列表index
    NSInteger proslIndex = 0;
    // 城市下拉列表index
    NSInteger citslIndex = 0;
    // 区下拉列表index
    NSInteger dicssIndex = 0;
    
    NSInteger pCount = [_pArray count];
    for (int i = 0; i < pCount; i++) {
        WSDictBean *dic = [_pArray objectAtIndex:i];
        NSInteger currentID = [dic.Id integerValue];
        if (provinceID == currentID) {
            proslIndex = i;
            break;
        }
    }
    
    NSInteger cCount = [_cArray count];
    for (int i = 0; i < cCount; i++) {
        WSDictBean *dic = [_cArray objectAtIndex:i];
        NSInteger currentID = [dic.Id integerValue];
        if (cityID == currentID) {
            citslIndex = i;
            break;
        }
    }
    
    NSInteger dCount = [_dArray count];
    for (int i = 0; i < dCount; i++) {
        WSDictBean *dic = [_dArray objectAtIndex:i];
        NSInteger currentID = [dic.Id integerValue];
        if (areaID == currentID) {
            dicssIndex = i;
            break;
        }
    }
    
    WSBaseDictsDBService *baseDictsDBService = [[WSBaseDictsDBService alloc] init];
    self.pArray = [baseDictsDBService queryDictsWithParentId:nil filter:@"geography"];
    
    WSDictBean *firstProDictBean = [_pArray objectAtIndex:proslIndex];
    self.cArray = [NSMutableArray arrayWithArray:[baseDictsDBService queryDictsWithParentId:firstProDictBean.Id filter:@"geography"]];
    
    WSDictBean *firstCityDictBean = [_cArray objectAtIndex:citslIndex];
    self.dArray = [NSMutableArray arrayWithArray:[baseDictsDBService queryDictsWithParentId:firstCityDictBean.Id filter:@"geography"]];
    

    
    CGFloat width = CGRectGetWidth(self.bounds);
    self.prosl = [[SelectListControl alloc] init];
    _prosl.selectListDelegate = self;
    _prosl.frame = CGRectMake(0, 0, width, 30);
    _prosl.content = [[NSMutableArray alloc] init];
    for (WSDictBean *dic in _pArray)
    {
        NSString *pName = dic.name;
        [_prosl.content addObject:pName];
    }
    _prosl.title = @"省";
    _prosl.selectedIndex = proslIndex;
    [self addSubview:_prosl];
    
    self.citsl = [[SelectListControl alloc] initWithFrame:CGRectMake(0, 40, width, 30)];
    _citsl.selectListDelegate = self;
    for (WSDictBean *dic in _cArray)
    {
        if (_citsl.content == nil)
        {
            _citsl.content = [[NSMutableArray alloc] init];
        }
        NSString *cName = dic.name;
        [_citsl.content addObject:cName];
    }
    _citsl.title = @"市";
    _citsl.selectedIndex = citslIndex;
    [self addSubview:_citsl];
    
    self.dicsl = [[SelectListControl alloc] initWithFrame:CGRectMake(0, 80, width, 30)];
    _dicsl.selectListDelegate = self;
    for (WSDictBean *dic in _dArray)
    {
        if (_dicsl.content == nil)
        {
            _dicsl.content = [[NSMutableArray alloc] init];
        }
        NSString *cName = dic.name;
        [_dicsl.content addObject:cName];
    }
    _dicsl.title = @"县";
    _dicsl.selectedIndex = dicssIndex;
    [self addSubview:_dicsl];
    
    // 如果街道的名字存在 则添加街道标题和需要输入内容的文本框
    NSString *streetName = [self.preInfoDic objectForKey:@"streetName"];
    if (streetName && [streetName isKindOfClass:[NSString class]]) {
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 60, 24)];
        label.text = @"街道:";
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        [self addSubview:label];
        
        self.streetTextField = [[UITextField alloc]initWithFrame:CGRectMake(50, 120, 260, 24)];
        _streetTextField.borderStyle = UITextBorderStyleRoundedRect;
        
        NSString *input = NSLocalizedString(@"please_fill_in", nil);
        _streetTextField.placeholder = input;
        _streetTextField.returnKeyType = UIReturnKeyDone;
        _streetTextField.font = font;
        _streetTextField.delegate = self;
        if (streetName) {
            _streetTextField.text = streetName;
        }
        [self addSubview:_streetTextField];
    }
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withPreInfoDic:nil];
}


#pragma mark - delegate & datasource
- (void)selectListChange:(SelectListControl *)aSelectListControl
{
    if (self.selectListDataSourceMode == SelectListDataSourceFromCityDataFileMode) {
        if (aSelectListControl == _prosl)
        {
            NSDictionary *cityDic = [_pArray objectAtIndex:aSelectListControl.selectedIndex];
            NSArray *citys = [cityDic objectForKey:kCitys];
            self.cArray = [NSMutableArray arrayWithArray:citys];
            [_citsl.content removeAllObjects];
            
            for (NSDictionary *dic in _cArray)
            {
                if (_citsl.content == nil)
                {
                    _citsl.content = [[NSMutableArray alloc] init];
                }
                NSString *cName = [dic objectForKey:@"name"];
                [_citsl.content addObject:cName];
            }
            _citsl.selectedIndex = 0;
            [_citsl reloadData];
            
            NSDictionary *dicDic = [_cArray firstObject];
            NSArray *dics = [dicDic objectForKey:kAreas];
            self.dArray = [NSMutableArray arrayWithArray:dics];
            [_dicsl.content removeAllObjects];
            for (NSDictionary *dic in _dArray)
            {
                if (_dicsl.content == nil)
                {
                    _dicsl.content = [[NSMutableArray alloc] init];
                }
                NSString *cName = [dic objectForKey:@"name"];
                [_dicsl.content addObject:cName];
            }
            _dicsl.selectedIndex = 0;
            [_dicsl reloadData];
        }
        else if (aSelectListControl == _citsl)
        {
            NSDictionary *dicDic = [_cArray objectAtIndex:aSelectListControl.selectedIndex];
            NSArray *dics = [dicDic objectForKey:kAreas];
            self.dArray = [NSMutableArray arrayWithArray:dics];
            [_dicsl.content removeAllObjects];
            for (NSDictionary *dic in _dArray)
            {
                if (_dicsl.content == nil)
                {
                    _dicsl.content = [[NSMutableArray alloc] init];
                }
                NSString *cName = [dic objectForKey:@"name"];
                [_dicsl.content addObject:cName];
            }
            _dicsl.selectedIndex = 0;
            [_dicsl reloadData];
            
        }
    }else{
        [self selectListChangeWithDataSourceFromDictsTableMode:aSelectListControl];
    }
    
    
    if (self.addressPickerDelegate != nil && [self.addressPickerDelegate respondsToSelector:@selector(addressPickerViewAddressChanged:)])
    {
        [self.addressPickerDelegate performSelector:@selector(addressPickerViewAddressChanged:) withObject:self];
    }
}

- (void)selectListChangeWithDataSourceFromDictsTableMode:(SelectListControl *)aSelectListControl
{
    WSBaseDictsDBService *baseDictsDBService = [[WSBaseDictsDBService alloc] init];

    if (aSelectListControl == _prosl)
    {
        WSDictBean *proDictBean = [_pArray objectAtIndex:aSelectListControl.selectedIndex];
        self.cArray = [NSMutableArray arrayWithArray:[baseDictsDBService queryDictsWithParentId:proDictBean.Id filter:@"geography"]];
        [_citsl.content removeAllObjects];
        
        for (WSDictBean *dic in _cArray)
        {
            if (_citsl.content == nil)
            {
                _citsl.content = [[NSMutableArray alloc] init];
            }
            NSString *cName = dic.name;
            [_citsl.content addObject:cName];
        }
        _citsl.selectedIndex = 0;
        [_citsl reloadData];
        
        WSDictBean *dicDic = [_cArray firstObject];
        self.dArray = [NSMutableArray arrayWithArray:[baseDictsDBService queryDictsWithParentId:dicDic.Id filter:@"geography"]];
        [_dicsl.content removeAllObjects];
        for (WSDictBean *dic in _dArray)
        {
            if (_dicsl.content == nil)
            {
                _dicsl.content = [[NSMutableArray alloc] init];
            }
            NSString *cName = dic.name;
            [_dicsl.content addObject:cName];
        }
        _dicsl.selectedIndex = 0;
        [_dicsl reloadData];
    }
    else if (aSelectListControl == _citsl)
    {
        WSDictBean *dicDic = [_cArray objectAtIndex:aSelectListControl.selectedIndex];
        self.dArray = [NSMutableArray arrayWithArray:[baseDictsDBService queryDictsWithParentId:dicDic.Id filter:@"geography"]];
        [_dicsl.content removeAllObjects];
        for (WSDictBean *dic in _dArray)
        {
            if (_dicsl.content == nil)
            {
                _dicsl.content = [[NSMutableArray alloc] init];
            }
            NSString *cName = dic.name;
            [_dicsl.content addObject:cName];
        }
        _dicsl.selectedIndex = 0;
        [_dicsl reloadData];
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.addressPickerDelegate != nil && [self.addressPickerDelegate respondsToSelector:@selector(addressPickerViewAddressChanged:)])
    {
        [self.addressPickerDelegate performSelector:@selector(addressPickerViewAddressChanged:) withObject:self];
    }
    
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (NSDictionary *)resultWithDic {
    if (self.selectListDataSourceMode == SelectListDataSourceFromCityDataFileMode) {
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] initWithCapacity:7];
        
        NSString *provinceID = [[_pArray objectAtIndex:_prosl.selectedIndex] objectForKey:@"id"];
        if (provinceID) {
            [resultDic setObject:provinceID forKey:kProvinceID];
        }
        NSString *provinceName = [[_pArray objectAtIndex:_prosl.selectedIndex] objectForKey:@"name"];
        if (provinceName) {
            [resultDic setObject:provinceName forKey:kProvinceName];
        }
        
        NSString *cityID = [[_cArray objectAtIndex:_citsl.selectedIndex] objectForKey:@"id"];
        if (cityID) {
            [resultDic setObject:cityID forKey:kCityID];
        }
        NSString *cityName = [[_cArray objectAtIndex:_citsl.selectedIndex] objectForKey:@"name"];
        if (cityName) {
            [resultDic setObject:cityName forKey:kCityName];
        }
        
        NSString *areaID = [[_dArray objectAtIndex:_dicsl.selectedIndex] objectForKey:@"id"];
        if (areaID) {
            [resultDic setObject:areaID forKey:kAreaID];
        }
        NSString *areaName = [[_dArray objectAtIndex:_dicsl.selectedIndex] objectForKey:@"name"];
        if (areaName) {
            [resultDic setObject:areaName forKey:kAreaName];
        }
        
        NSString *streetName = _streetTextField.text;
        if (streetName) {
            [resultDic setObject:streetName forKey:kStreetName];
        }
        
        if(self.address)
        {
            [resultDic setObject:self.address forKey:kAddress];
        }
        
        
        return resultDic;
    }else{
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] initWithCapacity:7];
        
        WSDictBean *provinceDictBean = [_pArray objectAtIndex:_prosl.selectedIndex];
        NSString *provinceID = provinceDictBean.Id;
        
        if (provinceID) {
            [resultDic setObject:provinceID forKey:kProvinceID];
        }
        NSString *provinceName = provinceDictBean.name;
        if (provinceName) {
            [resultDic setObject:provinceName forKey:kProvinceName];
        }
        
        WSDictBean *cityDictBean = [_cArray objectAtIndex:_citsl.selectedIndex];
        NSString *cityID = cityDictBean.Id;
        if (cityID) {
            [resultDic setObject:cityID forKey:kCityID];
        }
        NSString *cityName = cityDictBean.name;
        if (cityName) {
            [resultDic setObject:cityName forKey:kCityName];
        }
        
        WSDictBean *areaDictBean = [_dArray objectAtIndex:_dicsl.selectedIndex];
        NSString *areaID = areaDictBean.Id;
        if (areaID) {
            [resultDic setObject:areaID forKey:kAreaID];
        }
        NSString *areaName = areaDictBean.Id;
        if (areaName) {
            [resultDic setObject:areaName forKey:kAreaName];
        }
        
        NSString *streetName = _streetTextField.text;
        if (streetName) {
            [resultDic setObject:streetName forKey:kStreetName];
        }

        if(self.address)
        {
            [resultDic setObject:self.address forKey:kAddress];
        }
        
        
        return resultDic;
    }
    
    
}

- (NSString *)address {
    NSString *address = @"";
    NSString *provinceString = @"";
    NSString *cityString = @"";
    NSString *districtString = @"";

    if (self.selectListDataSourceMode == SelectListDataSourceFromCityDataFileMode) {
        provinceString = [[_pArray objectAtIndex:_prosl.selectedIndex] objectForKey:@"name"];
        cityString = [[_cArray objectAtIndex:_citsl.selectedIndex] objectForKey:@"name"];
        districtString = [[_dArray objectAtIndex:_dicsl.selectedIndex] objectForKey:@"name"];
    }else{
        WSDictBean *provinceDictBean = [_pArray objectAtIndex:_prosl.selectedIndex];
        WSDictBean *cityDictBean = [_cArray objectAtIndex:_citsl.selectedIndex];
        WSDictBean *areaDictBean = [_dArray objectAtIndex:_dicsl.selectedIndex];
        provinceString = provinceDictBean.name;
        cityString = cityDictBean.name;
        districtString = areaDictBean.name;
    }
    
    if (provinceString) {
        address = [address stringByAppendingString:provinceString];
    }
    if (cityString) {
        address = [address stringByAppendingString:cityString];
    }
    if (districtString) {
        address = [address stringByAppendingString:districtString];
    }
    NSString *streetString = _streetTextField.text;
    if (streetString) {
        address = [address stringByAppendingString:streetString];
    }
    if ([address length] > 0) {
        return address;
    }
    return nil;
}

#pragma mark - private API
- (NSString *)codeAddress {
    NSString *provinceString = nil;
    NSString *cityString = nil;
    NSString *districtString = nil;
    NSString *streetString = nil;
    
    if (self.selectListDataSourceMode == SelectListDataSourceFromCityDataFileMode) {
        provinceString = [[_pArray objectAtIndex:_prosl.selectedIndex] objectForKey:@"id"];
        cityString = [[_cArray objectAtIndex:_citsl.selectedIndex] objectForKey:@"id"];
        districtString = [[_dArray objectAtIndex:_dicsl.selectedIndex] objectForKey:@"id"];
    }else{
        WSDictBean *provinceDictBean = [_pArray objectAtIndex:_prosl.selectedIndex];
        WSDictBean *cityDictBean = [_cArray objectAtIndex:_citsl.selectedIndex];
        WSDictBean *areaDictBean = [_dArray objectAtIndex:_dicsl.selectedIndex];

        provinceString = provinceDictBean.Id;
        cityString = cityDictBean.Id;
        districtString = areaDictBean.Id;
    }

    streetString = _streetTextField.text;
    
    NSString *finalString = [NSString stringWithFormat:@"%@,%@,%@,%@", provinceString, cityString,districtString, streetString];
    
    return finalString;
}



@end
