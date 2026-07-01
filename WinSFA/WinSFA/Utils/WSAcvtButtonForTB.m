//
//  WSAcvtButtonForTB.m
//  WinSFA
//
//  Created by xiaotang.wang on 9/2/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSAcvtButtonForTB.h"

@implementation WSAcvtButtonForTB

@synthesize iNotificationPrefix = _iNotificationPrefix;
@synthesize iRow = _iRow;
@synthesize iColumn = _iColumn;
@synthesize iDataType = _iDataType;
@synthesize iIdentifyId = _iIdentifyId;
@synthesize iDicNotificationName = _iDicNotificationName;
@synthesize iLogicType = _iLogicType;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _hasBeenFilled = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

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
//    NSLog(@"%s---%d", __FUNCTION__, __LINE__);
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

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}

//- (NSString *)getTextValue
//{
//    return self.text;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
