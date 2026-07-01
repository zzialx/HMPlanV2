//
//  MultipeerManager.m
//  WinSFA
//
//  Created by zhangke on 14/12/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "MultipeerManager.h"
#import "WSSubempstoreBeanArray.h"


static NSString * const kMCSessionServiceType = @"mcsessionp2p";

static MultipeerManager* _multipeerManager=nil;

@implementation MultipeerManager


+(MultipeerManager*)sharedManager
{
    if(_multipeerManager==nil){
        _multipeerManager=[[MultipeerManager alloc] init];
    }
    return _multipeerManager;
}


- (void)startServices
{
    NSMutableArray* array=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"peerArray"]];
    NSPredicate* pre=[NSPredicate predicateWithFormat:@"%@==%@",PEERID, [[NSUserDefaults standardUserDefaults] objectForKey:PEERID]];
    NSDictionary* dic =[[array filteredArrayUsingPredicate:pre] firstObject];
    [array removeObject:dic];
    
    NSMutableArray* deleteArray=[NSMutableArray array];
    for(NSDictionary* dic in array){
        NSDate* date=[dic objectForKey:@"date"];
        NSInteger compare=[date compareWithToday];
        if(compare<0){
            [deleteArray addObject:dic];
        }
    }
    [array removeObjectsInArray:deleteArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"peerArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:PEERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    [self setupSession];
    [self.serviceAdvertiser startAdvertisingPeer];
    [self.serviceBrowser startBrowsingForPeers];
}


- (void)stopServices
{
    [self.serviceBrowser stopBrowsingForPeers];
    [self.serviceAdvertiser stopAdvertisingPeer];
    [self.session disconnect];
    [self stopSession];
}


- (void)setupSession
{
    NSString* user=[[NSUserDefaults standardUserDefaults] objectForKey:PEERID];
    
    if(user){
        self.peerID = [[MCPeerID alloc] initWithDisplayName:user];
        
        // Create the session that peers will be invited/join into.
        self.session = [[MCSession alloc] initWithPeer:self.peerID];
        self.session.delegate = self;
        
        // Create the service browser
        self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                               serviceType:kMCSessionServiceType];
        self.serviceBrowser.delegate = self;
        
        
        // Create the service advertiser
        self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
                                                                   discoveryInfo:nil
                                                                     serviceType:kMCSessionServiceType];
        self.serviceAdvertiser.delegate = self;
    }

    

}

-(void)stopSession
{
    NSArray* array=[[NSUserDefaults standardUserDefaults] objectForKey:@"peerArray"];
    NSMutableArray* newarray=[NSMutableArray array];
    
    for(NSDictionary* dic in array){
        NSMutableDictionary* newdic=[NSMutableDictionary dictionaryWithDictionary:dic];
        [newdic setObject:@"0" forKey:@"online"];
        [newarray addObject:newdic];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newarray forKey:@"peerArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    self.peerID=nil;
    self.session=nil;
    self.serviceAdvertiser=nil;
    self.serviceBrowser=nil;
    _multipeerManager=nil;
}




- (NSString *)stringForPeerConnectionState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected";
            
        case MCSessionStateConnecting:
            return @"Connecting";
            
        case MCSessionStateNotConnected:
            return @"Not Connected";
    }
}

#pragma mark - MCSessionDelegate protocol conformance

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if([peerID.displayName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PEERID]]){
        return;
    }
    NSLog(@"Peer [%@] changed state to %@", peerID.displayName, [self stringForPeerConnectionState:state]);

    NSMutableArray* array=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"peerArray"]];
    
    if(state==MCSessionStateConnected){
        
        if(array.count==0){
            NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:peerID.displayName,PEERID,[NSDate date],@"date",@"1",@"online", nil];
            [array addObject:dic];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"peerArray"];
            
        }else{
            
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"peerID==%@",peerID.displayName];
            NSArray* filterArray=[array filteredArrayUsingPredicate:pre];
            if(filterArray.count>0){
                NSDictionary* dic=filterArray.firstObject;
                NSDictionary* newDic=[NSDictionary dictionaryWithObjectsAndKeys:peerID.displayName,PEERID,[NSDate date],@"date",@"1",@"online", nil];
                [array replaceObjectAtIndex:[array indexOfObject:dic] withObject:newDic];
                [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"peerArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                NSDictionary* newDic=[NSDictionary dictionaryWithObjectsAndKeys:peerID.displayName,PEERID,[NSDate date],@"date",@"1",@"online", nil];
                [array addObject:newDic];
                [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"peerArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }
        
    }else{
        
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"peerID==%@",peerID.displayName];
        NSArray* filterArray=[array filteredArrayUsingPredicate:pre];
        if(filterArray.count>0){
            NSDictionary* dic=filterArray.firstObject;
            NSDictionary* newDic=[NSDictionary dictionaryWithObjectsAndKeys:peerID.displayName,PEERID,[NSDate date],@"date",@"0",@"online", nil];
            NSInteger index=[array indexOfObject:dic];
            [array replaceObjectAtIndex:index withObject:newDic];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"peerArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
    
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
}

-(void)reloadData
{
    [self.delegate reloadMultipeerData];
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}


#pragma mark - MCNearbyServiceBrowserDelegate protocol conformance

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSString *remotePeerName = peerID.displayName;
    
    if(![peerID.displayName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PEERID]]){
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0];
        NSLog(@"Inviting %@", remotePeerName);
        
    }
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"lostPeer %@", peerID.displayName);
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate protocol conformance

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    if(![peerID.displayName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PEERID]]){
        invitationHandler(YES, self.session);
        NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
        
    }
    
}





@end
