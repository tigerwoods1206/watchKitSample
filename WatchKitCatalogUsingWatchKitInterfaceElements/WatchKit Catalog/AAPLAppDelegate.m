/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
   The application delegate which creates the window and root view controller.
  
 */

#import "AAPLAppDelegate.h"

@implementation AAPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
     */
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [self registerUserNotificationSettings];
    }

    
    return YES;
}

// アプリがBackground起動になったときに処理
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // LocalNotificationの送信
    //[self sendLocalNotificationForMessage:@"TEST"];
}


// LocalNotificationでアクションを実行したときの処理
- (void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"ACCEPT"]) {
        NSLog(@"Accepted");
    } else if([identifier isEqualToString:@"MAYBE"]) {
        NSLog(@"Maybe");
    } else if([identifier isEqualToString:@"DECLINE"]) {
        NSLog(@"Declined");
    } else if ([identifier isEqualToString:@"firstButtonAction"]) {
        NSLog(@"firstButtonAction");
        [self sendLocalNotificationForMessage:@"firstButtonAction"];
    }
    
    if(completionHandler) {
        completionHandler();
    }
}
- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.category = @"myCategory"; // Action表示させたいCategoryの設定
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"firstButtonAction"]) {
        // ...
        [self sendLocalNotificationForMessage:@"firstButtonAction"];
    }     
    
    if (completionHandler) {
        completionHandler();
    }
    
}

// Notificationの設定
- (void)registerUserNotificationSettings
{
    // Actionの生成
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"firstButtonAction";
    acceptAction.title = @"First Button";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.authenticationRequired = NO;
    acceptAction.destructive = NO;
    
       // Categoryの作成
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"myCategory"; // CategoryのIDを設定
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault]; // ダイアログ表示
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal]; // バナー表示
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

@end
