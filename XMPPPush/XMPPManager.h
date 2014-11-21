//
//  XMPPManager.h
//  LongSocket+LocalNotification
//
//  Created by nonato on 14-11-21.
//  Copyright (c) 2014年 Nonato. All rights reserved.
//
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "MMPushService.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "DDXML.h"

//ip 120.24.82.164 192.168.21.229
typedef void (^RostersBlock)   (XMPPIQ *iq);
typedef void (^NewMessageBlock)(XMPPMessage *message);
typedef void (^PresenceBlock)  (XMPPPresence *presence);

#define XMPP_USERNAME       @"testtttt3"
#define XMPP_DOMAIN         @"120.24.82.164"
#define XMPP_RESOURCE       @"AndroidpnClient"
#define APPJID  [NSString stringWithFormat:@"%@@%@/%@",XMPP_USERNAME,XMPP_DOMAIN,XMPP_RESOURCE]
#define XMPP_PASSWORD       @"testtttt3"
#define XMPP_APPID          @"9876543210"
#define XMPP_OS             @"iOS"
#define XMPP_MODEL          @"iphone6 plus"
#define XMPP_VERSION        @"V5.0"

@interface XMPPManager : NSObject

//---------------------------------------------------------------------
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
//@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
//@property (nonatomic, strong) XMPPRoster *xmppRoster;
//@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
//@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;

//-------------------------- 好友列表 好友消息 状态刷新
@property (nonatomic,copy) RostersBlock rosterblock;
@property (nonatomic,copy) NewMessageBlock newmessageblock;
@property (nonatomic,copy) PresenceBlock presenceblock;
-(void)connect:(NSXMLElement *)iq RostersBlock:(RostersBlock)RostersBlock NewMessageBlock:(NewMessageBlock) NewMessageBlock PresenceBlock:(PresenceBlock)PresenceBlock;
//---------------------------------------------------------------------
+ (XMPPManager *)sharedInstance;

@end
