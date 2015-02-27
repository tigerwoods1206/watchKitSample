/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This controller displays the Glance. It demonstrates passing information, via Handoff, to the Watch app to route the wearer to the appropriate controller once the app is launched. Tapping on the Glance will launch the Watch app.
  
 */

#import "AAPLGlanceController.h"

@interface AAPLGlanceController()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *glanceImage;

@end


@implementation AAPLGlanceController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];

    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
    }

    return self;
}

- (void)willActivate {
    // This method is called when the controller is about to be visible to the wearer.
    NSLog(@"%@ will activate", self);
    
    // Load image from WatchKit Extension.
    NSData *imageData;
    
    if ([[WKInterfaceDevice currentDevice] screenBounds].size.width > 136.0) {
        imageData = UIImagePNGRepresentation([UIImage imageNamed:@"42mm-Walkway"]);
    } else {
        imageData = UIImagePNGRepresentation([UIImage imageNamed:@"38mm-Walkway"]);
    }

    [self.glanceImage setImageData:imageData];
    
    // Use Handoff to route the wearer to the image detail controller when the Glance is tapped.
    [self updateUserActivity:@"com.example.apple-samplecode.WatchKit-Catalog" userInfo:@{
        @"controllerName": @"imageDetailController",
        @"detailInfo": @"This is some more detailed information to pass."
    }];
}

- (void)didDeactivate {
    // This method is called when the controller is no longer visible.
    NSLog(@"%@ did deactivate", self);
}

@end
