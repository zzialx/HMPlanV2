//
//  WSRichItemModel.m
//  WinSFA
//
//  Created by huzepei on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichItemModel.h"

@implementation WSRichItemModel

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.ID forKey:@"ID"];
    [encoder encodeObject:self.speid forKey:@"speid"];
    [encoder encodeObject:self.cod forKey:@"cod"];
    [encoder encodeObject:self.typ forKey:@"typ"];
    [encoder encodeObject:self.memo forKey:@"memo"];
    [encoder encodeObject:self.img_url forKey:@"img_url"];
    [encoder encodeObject:self.h5_url forKey:@"h5_url"];
    [encoder encodeObject:self.levelCode forKey:@"levelCode"];
    [encoder encodeObject:self.h5_add forKey:@"h5_add"];
    [encoder encodeObject:self.img_add forKey:@"img_add"];
    [encoder encodeObject:self.fenleiId forKey:@"fenleiId"];
    [encoder encodeObject:self.isread forKey:@"isread"];
    [encoder encodeObject:self.share_url forKey:@"share_url"];
    [encoder encodeObject:self.type_ forKey:@"type_"];
    [encoder encodeObject:self.clicktime forKey:@"clicktime"];


}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        
        self.name = [decoder decodeObjectForKey:@"name"];
        self.speid = [decoder decodeObjectForKey:@"speid"];
        self.ID = [decoder decodeObjectForKey:@"ID"];
        self.cod = [decoder decodeObjectForKey:@"cod"];
        self.typ = [decoder decodeObjectForKey:@"typ"];
        self.memo = [decoder decodeObjectForKey:@"memo"];
        self.img_url = [decoder decodeObjectForKey:@"img_url"];
        self.levelCode = [decoder decodeObjectForKey:@"levelCode"];
        self.h5_url = [decoder decodeObjectForKey:@"h5_url"];
        self.h5_add = [decoder decodeObjectForKey:@"h5_add"];
        self.img_add = [decoder decodeObjectForKey:@"img_add"];
        self.fenleiId = [decoder decodeObjectForKey:@"fenleiId"];
        self.isread = [decoder decodeObjectForKey:@"isread"];
        self.share_url = [decoder decodeObjectForKey:@"share_url"];
        self.type_ = [decoder decodeObjectForKey:@"type_"];
        self.clicktime = [decoder decodeObjectForKey:@"clicktime"];

    }
    return self;
}



@end
