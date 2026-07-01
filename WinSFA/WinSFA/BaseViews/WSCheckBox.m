//
//  WSCheckBox.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-9-17.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSCheckBox.h"

@interface WSCheckBox ()


@property (nonatomic, assign)BOOL iIsObserver;

@end

@implementation WSCheckBox

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
  
    if (self.iDataType == WSValidateDataIsDepended && self.iIsObserver == YES) {
        [self removeObserver:self forKeyPath:@"selected" context:nil];
    }
}

#pragma mark - WSValidateData protocal
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
//    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
//    self.iRow = aRow;
//    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
//        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
//    NSLog(@"%d--%s-----%p-----%d", __LINE__, __FUNCTION__, self, self.iDataType);
    if (self.iDataType == WSValidateDataIsDepended) {
        [self addObserver:self
               forKeyPath:@"selected"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                  context:nil];
        self.iIsObserver = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    
    if (keyPath != nil && [keyPath isEqualToString:@"selected"]) {
        id new = [change objectForKey:@"new"];
//        NSNumber *number = nil;
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
//        if ([new isKindOfClass:[NSNull class]]) {
//            number = [NSNumber numberWithBool:NO];
//        }else if([new isKindOfClass:[NSString class]]){
//            NSString *str = (NSString *)new;
//            BOOL flag = NO;
//            if (str != nil && [str length] > 0) {
//                flag = YES;
//            }
//            number = [NSNumber numberWithBool:flag];
//        }
        if ([new isKindOfClass:[NSNumber class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:new userInfo:nil];
        }
    }
}


- (void)updateState:(NSNotification *)sender
{
//    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        [self setEnabled:isEnable];
    }
}


/*WSCheckBox类型 不选中时默认值为0(总是合法)*/
- (BOOL)isValueLegal {
    if (self.selected) {
        return YES;
    }
    else{
        if (_isClicked) {
            return YES;
        }else
            return NO;
    }
    return YES;
}

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}
// SFA 箭牌 WRIGLEY-1678  安卓逻辑，只要给按钮设置过值，则证明按钮被操作过
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    if (self.iDataType == WSValidateDataIsDepended) {
        NSNumber *number = [NSNumber numberWithBool:selected];
        
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
    }
    
    _isClicked = YES;
    
}
//- (NSString *)getTextValue
//{
//    return self.text;
//}

@end
