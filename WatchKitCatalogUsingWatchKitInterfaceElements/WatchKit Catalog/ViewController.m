//
//  ViewController.m
//  WatchKit_Test_Parent
//
//  Created by ohtaisao on 2014/11/19.
//  Copyright (c) 2014年 isao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
-(IBAction)localPush:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)localPush:(id)sender {
    [self sendLocalNotificationForMessage:@"push"];
    
   // NSLog(@"notifications: %@", application.scheduledLocalNotifications);

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

@end
