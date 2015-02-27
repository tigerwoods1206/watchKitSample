/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This controller displays images, static and animated. It also demonstrates how to use screenBounds to use the most appropriate sized image for the device at runtime. Finally, this controller demonstrates loading images from the WatchKit Extension bundle and from the Watch app bundle.
  
 */

#import "AAPLImageDetailController.h"

@interface AAPLImageDetailController()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *staticImage;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *animatedImage;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *playButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *stopButton;

@end


@implementation AAPLImageDetailController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];

    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Log the context passed in, if the wearer arrived at this controller via the sample's Glance.
        NSLog(@"Passed in context: %@", context);
    }

    return self;
}

- (void)willActivate {
    // This method is called when the controller is about to be visible to the wearer.
    NSLog(@"%@ will activate", self);
    
    // Uses image in WatchKit Extension bundle.
    NSData *imageData;
    
    if ([[WKInterfaceDevice currentDevice] screenBounds].size.width > 136.0) {
        imageData = UIImagePNGRepresentation([UIImage imageNamed:@"42mm-Walkway"]);
    } else {
        imageData = UIImagePNGRepresentation([UIImage imageNamed:@"38mm-Walkway"]);
    }

    [self.staticImage setImageData:imageData];
}

- (void)didDeactivate {
    // This method is called when the controller is no longer visible.
    NSLog(@"%@ did deactivate", self);
}

- (IBAction)playAnimation {
    // Uses images in Watch app bundle.
    [self.animatedImage setImageNamed:@"Bus"];
    [self.animatedImage startAnimating];
    
    // Animate with a specific range, duration, and repeat count.
    // [self.animatedImage startAnimatingWithImagesInRange:NSMakeRange(0, 4) duration:2.0 repeatCount:3];
}

- (IBAction)stopAnimation {
    [self.animatedImage stopAnimating];
}

@end
