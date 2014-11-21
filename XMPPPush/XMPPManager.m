//
//  XMPPManager.m
//  LongSocket+LocalNotification
//
//  Created by nonato on 14-11-21.
//  Copyright (c) 2014年 Nonato. All rights reserved.
//

#import "XMPPManager.h"

@implementation XMPPManager

+ (XMPPManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static XMPPManager * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[XMPPManager alloc] init];
    });
    return sSharedInstance;
}

#pragma mark - xmpp
- (void)setupStream{
    _xmppStream = [[XMPPStream alloc]init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _xmppReconnect = [[XMPPReconnect alloc]init];
    [_xmppReconnect activate:_xmppStream];
    
}

- (BOOL)myConnect{
    NSString *jid = APPJID;
    NSString *ps = XMPP_PASSWORD;
    if (jid == nil || ps == nil) {
        return NO;
    }
    XMPPJID *myjid = [XMPPJID jidWithString:jid];
    NSError *error ;
    [_xmppStream setMyJID:myjid];
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"my connected error : %@",error.description);
        return NO;
    }
    return YES;
}

#pragma mark - 主要是这个方法获得更新
-(void)connect:(DDXMLElement *)iq RostersBlock:(RostersBlock)RostersBlock NewMessageBlock:(NewMessageBlock)NewMessageBlock PresenceBlock:(PresenceBlock)PresenceBlock
{
    //    if ([self.xmppStream isAuthenticated]) {
    if (!self.xmppStream) {
        [self setupStream];
    }
    
    if(![self.xmppStream isConnected])
    {
        [self myConnect];
    }
    if (iq) {
        [self.xmppStream sendElement:iq];
    }
    self.rosterblock =  ^(XMPPIQ *aiq){
        RostersBlock(aiq);
    };
    self.newmessageblock = ^(XMPPMessage * msg){
        NewMessageBlock(msg);
    };
    self.presenceblock = ^(XMPPPresence * presence){
        PresenceBlock(presence);
    };
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWillConnect");
}

#pragma mark - 连接成功后就开始验证
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
    //    if ([[NSUserDefaults standardUserDefaults]objectForKey:kPS]) {
    NSError *error ;
    XMPPDeprecatedDigestAuthentication *someAuth = [[XMPPDeprecatedDigestAuthentication alloc] initWithStream:self.xmppStream password:XMPP_PASSWORD];
    if (![self.xmppStream authenticate:someAuth error:&error]) {
        //        if (![self.xmppStream authenticateWithPassword:XMPP_PASSWORD error:&error]) {//这种方法不支持androidpn
        NSLog(@"error authenticate : %@",error.description);
    }
    //    }
}
#pragma mark - 注册了就自动登陆
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
    NSError *error ;
    XMPPDeprecatedDigestAuthentication *someAuth = [[XMPPDeprecatedDigestAuthentication alloc] initWithStream:self.xmppStream password:XMPP_PASSWORD];
    if ([self.xmppStream authenticate:someAuth error:&error]){
        NSLog(@"error authenticate : %@",error.description);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
     NSLog(@"当前用户已经存在");
    //    NSError *err  ;
    //    if (![self.xmppStream authenticateWithPassword:XMPP_PASSWORD error:&err ]) {
    //        NSLog(@"error authenticate : %@",error.description);
    //    }
}

#pragma - 为当前用户做认证，如果认证成功，则调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //此时，当前用户已经与后台openfire连接，但是在openfire中，当前用的状态是未登录状态，所以此时，
    NSLog(@"xmppStreamDidAuthenticate");
    
    //当前用户发送状态告知后台，这样其他的用户才能收到当前用户的上线通知。
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    //再次run，刷新open fire  发现当前用户的状态已经是上线了
    
}

/*
 注意：注册之前要创建连接，否则会报"Please wait until the stream is connected"的错误
 连接或者注册后需要做一次认证，并发送一个上线的消息，否则后台和其他用户都无法收到当前用户的上线消息，后台openfire中看到的当前用户是灰色的离线状态。
 注册之后如果要再次建立连接，最好断开后再创建，否则会报"Attempting to connect while already connected or connecting"的错误。
 */
#pragma mark - 验证失败了就自动注册
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate:%@",error.description);
    if([self.xmppStream isConnected] && [self.xmppStream supportsInBandRegistration])
    {
        XMPPJID *xmppjid = [XMPPJID jidWithUser:XMPP_USERNAME domain:XMPP_DOMAIN resource:XMPP_RESOURCE ];
        [self.xmppStream setMyJID:xmppjid];
        NSError *error ;
        NSMutableArray *elements = [NSMutableArray array];
        [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:XMPP_USERNAME]];
        [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:XMPP_PASSWORD]];
        
        //用户名和密码是必要的 以下的根据自己的服务器的需求添加额外信息
        [elements addObject:[NSXMLElement elementWithName:@"appid" stringValue:XMPP_APPID]];
        [elements addObject:[NSXMLElement elementWithName:@"os" stringValue:XMPP_OS]];
        [elements addObject:[NSXMLElement elementWithName:@"model" stringValue:XMPP_MODEL]];
        [elements addObject:[NSXMLElement elementWithName:@"version" stringValue:XMPP_VERSION]];
        
        if (![self.xmppStream registerWithElements:elements error:&error]) {
             NSLog(@"%@",error.description);
            }
    }
}
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
    NSLog(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return XMPP_RESOURCE;
}

#pragma mark - 获得好友列表
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"didReceiveIQ: %@",iq.description);
    if (self.rosterblock) {
        self.rosterblock(iq);
    }
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"didReceiveMessage: %@",message.description);
    NSLog(@"%@",[[message elementForName:@"x"] elementForName:@"offlin" ]);
    if (self.newmessageblock) {
        self.newmessageblock(message);
    }
}


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"didReceivePresence: %@",presence.description);
    if(self.presenceblock)
        self.presenceblock(presence);
    
    if (presence.status) { 
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"didReceiveError: %@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSLog(@"didSendIQ:%@",iq.description);
    if (self.rosterblock) {
        self.rosterblock(iq);
    }
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"didSendMessage:%@",message.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    NSLog(@"didSendPresence:%@",presence.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"didFailToSendIQ:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"didFailToSendMessage:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    NSLog(@"didFailToSendPresence:%@",error.description);
}
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWasToldToDisconnect");
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"xmppStreamConnectDidTimeout");
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect: %@",error.description);
}

#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:@"add" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"yes", nil];
    alertView.tag =  1122;//tag_subcribe_alertView;
    [alertView show];
}

#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}
@end
