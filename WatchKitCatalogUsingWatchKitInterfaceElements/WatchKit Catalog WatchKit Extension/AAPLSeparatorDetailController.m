/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This controller displays separators and how to visually break up content onscreen.
  
 */

#import "AAPLSeparatorDetailController.h"

@implementation AAPLSeparatorDetailController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];

    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
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
