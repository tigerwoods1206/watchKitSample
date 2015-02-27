/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This controller displays labels and specialized labels (Date and Timer).
  
 */

#import "AAPLLabelDetailController.h"

@interface AAPLLabelDetailController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *customFontLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *coloredLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *timer;

@end


@implementation AAPLLabelDetailController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];

    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Custom fonts must be added to the Watch app target and referenced in the Watch app's Info.plist.
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Custom Font" attributes:@{
            NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12.0]
        }];

        [self.customFontLabel setAttributedText:attributedString];
        [self.coloredLabel setTextColor:[UIColor purpleColor]];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:10];
        [components setMonth:12];
        [components setYear:2015];
        [self.timer setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
        [self.timer start];
    }

    return self;
}

- (void)willActivate {
    // This method is called when the controller is about to be visible to the wearer.
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when the controller is no longer visible.
    NSLog(@"%@ did deactivate", self);
}

@end