//
//  MMPushService.m
//  yuxi-manager
//
//  Created by Guo Yu on 14-8-27.
//  Copyright (c) 2014年 ylink. All rights reserved.
//
#import "XMPPManager.h"
#import "MMPushService.h"
#import <UIKit/UIKit.h> 
#define kMQTTServerHost @"iot.eclipse.org"
#define kTopic @"MQTTExample/testcnpush"

@interface MMPushService()

//@property (nonatomic, strong) MQTTClient *client;


@end

@implementation MMPushService

+ (MMPushService *)sharedService {
	static dispatch_once_t predicate = 0;
	static MMPushService *object = nil;
    
	dispatch_once(&predicate, ^{ object = [[self class] new]; });
    
	return object;
}


- (void)reconnect {
    
    [[XMPPManager sharedInstance] connect:nil RostersBlock:^(XMPPIQ *iq) {
        if ([@"set" isEqualToString:iq.type]) {
            NSXMLElement *notify = iq.childElement;
            if ([@"notification" isEqualToString:notify.name]) {
                NSArray * children = notify.children;
                NSString * title = nil;
                NSString * content = nil;
                NSString * url = nil;
                NSString * typeid = nil;
                
                for (NSXMLElement * item in children) {
                    if ([@"title" isEqualToString:item.name]) {
                        title = item.stringValue;
                    }
                    else if([@"message" isEqualToString:item.name])
                    {
                        content = item.stringValue;
                    }
                    else if([@"uri" isEqualToString:item.name])
                    {
                        url = item.stringValue;
                    }
                    else if([@"typeid" isEqualToString:item.name])
                    {
                        typeid = item.stringValue;
                    }
                }
                if (title && content) {
                    [self sendNotification:title message:content Typeid:typeid url:url];
                }
            }
        }
    } NewMessageBlock:^(XMPPMessage *message) {
        /* xml格式
          <message xmlns="jabber:client" id="PcyMR-42" to="testtttt3@120.24.82.164" type="headline" from="admin@120.24.82.164/spark"><body>广播 推送 哈哈</body></message>
         
         <message xmlns="jabber:client" id="PcyMR-43" to="testtttt3@120.24.82.164" from="admin@120.24.82.164/spark">
            <body>普通消息</body>
         </message>
         */
//        if ([@"message" isEqualToString:message.type]) {
        // 接受普通消息和广播消息
            NSString * content = [NSString stringWithFormat:@"%@:%@",message.from,message.body];
            [self sendNotification:content];
//        }
    } PresenceBlock:^(XMPPPresence *presence) {
        
    }];
    //10分钟
    UIApplication *application = [UIApplication sharedApplication];
    [application setKeepAliveTimeout:600 handler:^{
//        [self sendNotification:@"timeout handler activited..."];
        [self reconnect];
    }];
}

- (void)sendNotification:(NSString*)message {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.repeatInterval = 0;
    [notification setAlertBody:[NSString stringWithFormat:@"%@",message]];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
     notification.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    [application scheduleLocalNotification:notification];
    
}

-(void)sendNotification:(NSString*)title message:(NSString *)message  Typeid:(NSString *)Typeid url:(NSString *)url
{
    
    UIApplication *application = [UIApplication sharedApplication];
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.repeatInterval = 0;
    [notification setAlertBody:[NSString stringWithFormat:@"%@:%@",title,message]];
    [notification setAlertAction:[NSString stringWithFormat:@"%@||%@",Typeid,url]];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
     notification.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    
    [application scheduleLocalNotification:notification];
}
@end
