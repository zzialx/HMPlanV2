//
//  PhotoTypeButton.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-5-9.
//
//

#import "PhotoTypeButton.h"
#import "WSPhotoGalleryViewController.h"
#import "NSString+MD5Addition.h"
#import "WSCurrentTime.h"
#import "SDImageCache.h"
#import "GetMD5byStr.h"

@interface PhotoTypeButton ()

@property (nonatomic, strong) UIButton *button;     //按键
@property (nonatomic, strong) UILabel *countLabel;  //数量标签

@property (nonatomic, assign) BOOL  isNeed;
@property (nonatomic, strong) NSArray  *originImageIDArray;

@end

@interface PhotoTypeButton (Tools)

- (void)setPhotoCountLabel; //设置照片数量标签方法

@end

@implementation PhotoTypeButton

@synthesize photoIDArray = _photoIDArray;
@synthesize button = _button;
@synthesize imageMD5 = _imageMD5;
@synthesize iNotificationPrefix = _iNotificationPrefix;
@synthesize iRow = _iRow;
@synthesize iColumn = _iColumn;
@synthesize iDataType = _iDataType;
@synthesize iDicNotificationName = _iDicNotificationName;
@synthesize iLogicType = _iLogicType;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (id)initWithFuncs:(WSFuncsBean *)func {
- (instancetype)init {
    self = [super init];
    if (self) {
        _photoIDArray = [[NSMutableArray alloc]init];
        self.isSupperLocalPhoto = NO;
        
//        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIColor *mainTintColor = MAIN_TINT_COLOT;
//        if (!mainTintColor) {
//            mainTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
//        }
//        NSString *title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"camera_capture", nil), (unsigned long)[self.photoIDArray count]];
//        [_button setTitle:title forState:UIControlStateNormal];
//        [_button setTitleColor:mainTintColor forState:UIControlStateNormal];
//        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//        UIFont *font = [UIFont boldSystemFontOfSize:13];
//        _button.titleLabel.font = font;
//        [self addSubview:_button];
        
        //2017-12-12-MENGNIU-1740 修改样式
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor clearColor];
        [_button setImage:[UIImage scaledImageForName:@"icon_table_camera_standard" ofType:@"png"] forState:UIControlStateNormal];
        [_button setImage:[UIImage scaledImageForName:@"icon_table_camera_standard" ofType:@"png"] forState:UIControlStateSelected];
        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = DETAIL_TEXT_COLOR;
        _countLabel.font = [UIFont boldSystemFontOfSize:10];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.clipsToBounds = YES;
        _countLabel.layer.masksToBounds = YES;
        [self addSubview:_countLabel];
        _countLabel.hidden = YES;
        [self setPhotoCountLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTitle:) name:PhotoTypeButton_Notification object:nil];
    }
    return self;
}

- (void)resetTitle:(id)sender {
//    NSString *title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"camera_capture", nil), (unsigned long)[self.photoIDArray count]];
//    [_button setTitle:title forState:UIControlStateNormal];
    [self setPhotoCountLabel];
    

    NSMutableArray *deleteImageIDArray = [NSMutableArray array];
    for (NSString *imageID in self.originImageIDArray) {
        if (![self.photoIDArray containsObject:imageID]) {
            [deleteImageIDArray addObject:imageID];
        }
    }
    _deleteIDArray = deleteImageIDArray;
}

- (void)layoutSubviews {
//    CGRect rect = self.frame;
//    rect.origin = CGPointZero;
//    _button.frame = rect;
//    NSString *title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"camera_capture", nil), (unsigned long)[self.photoIDArray count]];
//    [_button setTitle:title forState:UIControlStateNormal];
    
    [super layoutSubviews];
    
    self.button.frame = self.bounds;
    [self setPhotoCountLabel];
}

- (void)buttonClick:(id)sender {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(photoTypeButtonClick:)]) {
        [self.customDelegate performSelector:@selector(photoTypeButtonClick:) withObject:self];
    }
}

+ (NSString *)getPhotoMD5:(UIImage *)aImage {
    NSString *str = [NSString stringWithFormat:@"%@, %@", [aImage description], [WSCurrentTime getDateString]];
    return [NSString md5:str];
}


#pragma mark - 

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
//    NSLog(@"%d--%s---%p", __LINE__, __FUNCTION__,self);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
//    self.iRow = aRow;
//    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDicNotificationName == nil) {
        self.iDicNotificationName = [[NSMutableDictionary alloc] init];
    }
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        
        [self.iDicNotificationName setValue:[NSNumber numberWithInteger:WSValidateDataValueInitialize] forKey:notifyName];
        
//        LogInfo(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
    // Do nothing
}


- (void)setEnabled:(BOOL)enabled{
    [self setUserInteractionEnabled:enabled];
    self.button.enabled = enabled;
}


- (BOOL)entityIsEnable
{
    return [self isUserInteractionEnabled];
}


- (void)updateState:(NSNotification *)sender
{
//    NSLog(@"%d--%s---%p,row:%d, colum:%d", __LINE__, __FUNCTION__,self, self.iRow, self.iColumn);
    if (sender.name != nil) {
        NSArray *notifyNames = [self.iDicNotificationName allKeys];
        for (NSString *name in notifyNames) {
            
            //From other element
            NSNumber *sendObj = (NSNumber *)sender.object;
            BOOL isEnable = [sendObj boolValue];
            NSLog(@"isEnable:%d", isEnable);
            
            if ([sender.name isEqualToString:name]) {
                if (self.iLogicType == WSValidateDataLogicOR) {
                    self.isNeed = isEnable;
//                    if (isEnable) {
//                        [self.iDicNotificationName setValue:[NSNumber numberWithInteger:WSValidateDataValueEnable] forKey:name];
//                        self.userInteractionEnabled = isEnable;
//                        self.button.enabled = isEnable;
//                    }else{
//                        [self.iDicNotificationName setValue:[NSNumber numberWithInteger:WSValidateDataValueDisenable] forKey:name];
//                        BOOL disenable = [self findYesValueFromDic:self.iDicNotificationName exceptKey:name];
//                        if (disenable) {
//                            [self.photoArray removeAllObjects];
//                            [self.photoIDArray removeAllObjects];
//                            NSString *title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"camera_capture", nil), [self.photoIDArray count]];
//                            [_button setTitle:title forState:UIControlStateNormal];
//                            
//                            self.userInteractionEnabled = isEnable;
//                            self.button.enabled = isEnable;
//                        }
//                    }
                }else if (self.iLogicType == WSValidateDataLogicAND ||self.iLogicType == WSValidateDataLogicNone){
                    if (isEnable) {
                        [self.iDicNotificationName setValue:[NSNumber numberWithBool:isEnable] forKey:name];
                        BOOL bfind = [self findNoValueFromDic:self.iDicNotificationName exceptKey:name];
                        if (!bfind) {
                            self.userInteractionEnabled = isEnable;
                            self.button.enabled = isEnable;
                        }
                    }else{
                        [self.iDicNotificationName setValue:[NSNumber numberWithBool:isEnable] forKey:name];
                        [self.photoIDArray removeAllObjects];
                        
//                        NSString *title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"camera_capture", nil), (unsigned long)[self.photoIDArray count]];
//                        [_button setTitle:title forState:UIControlStateNormal];
                        [self setPhotoCountLabel];
                        
                        self.userInteractionEnabled = isEnable;
                        self.button.enabled = isEnable;                        
                    }
                    
                }else{
                    //Do nothing
                }
            }
            
        }
        
    }
    
}

- (BOOL)findYesValueFromDic:(NSDictionary *)aDic exceptKey:(NSString *)aKey
{
    BOOL disEnable = YES;
    NSArray *keys = [aDic allKeys];
    for (NSString *key in keys) {
//        if (![key isEqualToString:aKey]) {
            NSNumber *number = [aDic objectForKey:key];
            WSValidateDataValue value = [number intValue];
            if (value != WSValidateDataValueDisenable) {
                disEnable = NO;
                break;
            }
//        }
    }
    return disEnable;
}

- (BOOL)findNoValueFromDic:(NSDictionary *)aDic exceptKey:(NSString *)aKey
{
    BOOL bFind = NO;
    NSArray *keys = [aDic allKeys];
    for (NSString *key in keys) {
        if (![key isEqualToString:aKey]) {
            NSNumber *number = [aDic objectForKey:key];
            BOOL bflag = [number boolValue];
            if (!bflag) {
                bFind = YES;
            }
        }
    }
    return bFind;
}

- (void)setPhotoIDArray:(NSMutableArray *)photoIDArray
{
    self.originImageIDArray = [photoIDArray copy];
    
    _photoIDArray = photoIDArray;
}


- (BOOL)isValueLegal
{
    return (self.photoIDArray != nil && [self.photoIDArray count] > 0) ? YES : NO;
}

- (BOOL)isValueChange {
    return _isValueChange;
}

- (BOOL) isNeedValue
{
    if (self.isNeed && [self.photoIDArray count] == 0) {
        return YES;
    }
    
    return NO;
}

- (NSString *)getTextValue
{
    if ([self.photoIDArray count] > 0) {
        return [self.photoIDArray componentsJoinedByString:@","];
    }
    
    return nil;
}


@end

@implementation PhotoTypeButton (Tools)

#pragma mark - 设置照片数量标签方法
- (void)setPhotoCountLabel
{
    //NSString *title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"camera_capture", nil), [self.photoIDArray count]];
    //[_button setTitle:title forState:UIControlStateNormal];
    
    if(self.photoIDArray.count > 0)
    {
        NSString *text = [NSString stringWithFormat:@"%ld", self.photoIDArray.count];
        CGSize textSize = [text ws_sizeWithFont:self.countLabel.font constrainedToWidth:CGRectGetWidth(self.frame)];
        textSize.width += 5.0f;
        
        CGFloat x = CGRectGetWidth(self.frame) - textSize.width;
        CGFloat y = CGRectGetHeight(self.frame) / 2;
        CGFloat w = textSize.width;
        CGFloat h = textSize.height;
        self.countLabel.frame = CGRectMake(x, y, w, h);
        self.countLabel.layer.cornerRadius = 4.0f;
        self.countLabel.text = text;
        self.countLabel.hidden = NO;
    }
    else
        self.countLabel.hidden = YES;
}

@end
