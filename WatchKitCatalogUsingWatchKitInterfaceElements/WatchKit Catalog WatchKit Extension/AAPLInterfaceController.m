/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
     This is the initial interface controller for the Watch app. It loads the initial table of the app with data and responds to Handoff launching the Watch app.
  
 */

#import "AAPLInterfaceController.h"
#import "AAPLElementRowController.h"

@interface AAPLInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *interfaceTable;

@property (strong, nonatomic) NSArray *elementsList;

@end


@implementation AAPLInterfaceController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Retrieve the data. This could be accessed from the iOS app via a shared container.
        self.elementsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"]];
        
        [self loadTableRows];
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

- (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)remoteNotification {
    if ([identifier isEqualToString:@"firstButtonAction"]) {
        NSLog(@"remote push firstButton");

    }
}

- (void)handleActionWithIdentifier:(NSString *)identifier
              forLocalNotification:(UILocalNotification *)localNotification {
    if ([identifier isEqualToString:@"firstButtonAction"]) {
        NSLog(@"local push firstButton");
        
    }
}

- (NSString *)actionForUserActivity:(NSDictionary *)userActivity context:(id *)context {
    // Set the context to meaningful data that may be in userActivity. You can also set it to data you derive from userActivity.
    *context = userActivity[@"detailInfo"];

    // The string returned should be the scene's Identifier, set in Interface Builder, for the controller you want to route the wearer to.
    return userActivity[@"controllerName"];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSDictionary *rowData = self.elementsList[rowIndex];

    [self pushControllerWithName:rowData[@"controllerIdentifier"] context:nil];
}

- (void)loadTableRows {
    [self.interfaceTable setNumberOfRows:self.elementsList.count withRowType:@"default"];
    
    // Create all of the table rows.
    [self.elementsList enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
        AAPLElementRowController *elementRow = [self.interfaceTable rowControllerAtIndex:idx];
        
        [elementRow.elementLabel setText:rowData[@"label"]];
    }];
}

@end
