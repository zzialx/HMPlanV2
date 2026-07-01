//
//  MultipeerManager.h
//  WinSFA
//
//  Created by zhangke on 14/12/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define PEERID @"peerID"


@protocol MultipeerManagerDelegate

-(void)reloadMultipeerData;

@end



@interface MultipeerManager : NSObject<MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate,MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;

@property (nonatomic, weak) id<MultipeerManagerDelegate> delegate;


+(MultipeerManager*)sharedManager;

- (void)startServices;
- (void)stopServices;

@end
