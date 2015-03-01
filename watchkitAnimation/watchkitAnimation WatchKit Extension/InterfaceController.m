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
    //[self.imgSpriteAnimation setImageNamed:@"slime"];
    //[self.imgSpriteAnimation startAnimatingWithImagesInRange:NSMakeRange(0, 60) duration:1.0 repeatCount:0];
    [self animationWithArrays];
}


- (IBAction)firstButtonAction:(id)sender {
    
    NSDictionary *requst = @{@"request":@"Hello"};
    
    [InterfaceController openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            [self.label setText:[replyInfo objectForKey:@"response"]];
        }
        
    }];
}


- (IBAction)SecondButtonAction:(id)sender {
    [self.imgSpriteAnimation setHidden:NO];
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


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



