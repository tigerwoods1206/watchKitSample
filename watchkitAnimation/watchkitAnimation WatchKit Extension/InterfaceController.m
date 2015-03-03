//
//  InterfaceController.m
//  watchkitAnimation WatchKit Extension
//
//  Created by オオタ イサオ on 2015/03/01.
//  Copyright (c) 2015年 オオタ イサオ. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (weak,nonatomic) IBOutlet WKInterfaceImage *imgSpriteAnimation;
@property (weak,nonatomic) IBOutlet WKInterfaceLabel *label;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.imgSpriteAnimation setHidden:YES];
}


- (IBAction)firstButtonAction:(id)sender {
    [self.imgSpriteAnimation setImageNamed:@"slime"];
    [self.imgSpriteAnimation startAnimatingWithImagesInRange:NSMakeRange(0, 60) duration:1.0 repeatCount:0];
    [self.imgSpriteAnimation setHidden:NO];
    
}


- (IBAction)SecondButtonAction:(id)sender {
    [self animationWithArrays];
    [self.imgSpriteAnimation setHidden:NO];
}

-(void)gotoiOSAPP {
    NSDictionary *requst = @{@"request":@"OpenAPP"};
    //@{@"key1":@"value1",

    [InterfaceController openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            [self.label setText:[replyInfo objectForKey:@"response"]];
        }
        
    }];
}


-(void)animationWithArrays {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<4; i++) {
        NSString *imagename = [NSString stringWithFormat:@"slime%d",i];
        UIImage *imageSlime = [UIImage imageNamed:imagename];
        [array addObject:imageSlime];
    }
    UIImage *animatedimage = [UIImage animatedImageWithImages:array duration:1.0];
    [self.imgSpriteAnimation setImage:animatedimage];
    [self.imgSpriteAnimation startAnimatingWithImagesInRange:NSMakeRange(0, 60) duration:1.0 repeatCount:0];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    // Detect button identifier, decide which method to run
    NSLog(@"handleActionWithIdentifier");
    [self gotoiOSAPP];
}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



