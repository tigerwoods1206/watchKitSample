/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This controller displays switches and their various configurations.
  
 */

#import "AAPLSwitchDetailController.h"

@interface AAPLSwitchDetailController()

@property (weak, nonatomic) IBOutlet WKInterfaceSwitch *offSwitch;

@end


@implementation AAPLSwitchDetailController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];

    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        [self.offSwitch setOn:NO];
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

- (IBAction)switchAction:(BOOL)on {
    NSLog(@"Switch value changed to %i.", on);
}

@end

