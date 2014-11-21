//
//  AppDelegate.m
//  XMPPPush
//
//  Created by nonato on 14-11-21.
//  Copyright (c) 2014年 Nonato. All rights reserved.
//
#import "PushBoxViewController.h"
#import "AppDelegate.h"
#import "MMPushService.h"
#import "ViewController.h"
@interface AppDelegate ()<UIAlertViewDelegate>
{
    UINavigationController *navigationctr;
    NSString  * pushTitle;
    NSString  * pushMessage;
    NSString  * pushAction;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //需要推送设置 iOS8写法和其他系统版本不同需要注意
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *ctr = [[ViewController alloc] init];
    navigationctr =[[UINavigationController  alloc] initWithRootViewController:ctr];
    [navigationctr.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]}];
    [navigationctr.navigationBar setBarTintColor:[UIColor orangeColor]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.window.rootViewController = navigationctr;
    [self.window makeKeyAndVisible];
   
    //开启推送
    [[MMPushService sharedService] reconnect];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


#pragma mark - 建立长连接
- (void)applicationDidEnterBackground:(UIApplication *)application {
  
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                
                [[MMPushService sharedService] reconnect];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - 接受通知推送
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"alertBody : %@",notification.alertBody);
    NSLog(@"alertAction : %@",notification.alertAction);
//    [self showAlertView:notification.alertBody];
    NSArray * array =[notification.alertBody componentsSeparatedByString:@":"];
    if (array.count == 2) {
        pushTitle = [array objectAtIndex:0];
        pushMessage = [array objectAtIndex:1];
    }
    NSArray * actionArray =[notification.alertAction componentsSeparatedByString:@"||"];
    if (actionArray.count == 2) {
        pushAction = notification.alertAction;
    }
    [self showAlertView:notification.alertBody];
}

#pragma mark - my method
-(void)showAlertView:(NSString *)message
{
    UIAlertView *alertView = nil;
    if (pushAction) {
        alertView = [[UIAlertView alloc]initWithTitle:pushTitle message:pushMessage delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"查看", nil];
    }
    else
    {
        alertView = [[UIAlertView alloc]initWithTitle:pushTitle message:pushMessage delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    }
    alertView.tag = 1615;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (pushAction) {
            NSArray * array =[pushAction componentsSeparatedByString:@"||"];
            if (array.count == 2) {
//                NSString * typeid = [array objectAtIndex:0];
                NSString * url = [array objectAtIndex:1];
                if (url.length) {
                    PushBoxViewController * ctr =[[PushBoxViewController alloc] init];
                    ctr.title = pushTitle;
                    [ctr loadWebView:url];
                    [navigationctr pushViewController:ctr animated:YES];
                }
            }
        }
    }
    else
    {
        
    }
}
@end
