//
//  InterfaceController.m
//  WatchKit_OpenGL WatchKit Extension
//
//  Created by ohtaisao on 2014/11/20.
//  Copyright (c) 2014年 isao. All rights reserved.
//

#import "InterfaceController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@interface InterfaceController()
//@property (strong, nonatomic) EAGLContext *context;
//@property (strong, nonatomic) GLKBaseEffect *effect;
//@property (strong, nonatomic) UIView *view;
@end


@implementation InterfaceController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
   // self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
  //  if (!self.context) {
    //    NSLog(@"Failed to create ES context");
   // }
    
    
    //GLKView *view = (GLKView *)self.view;
  //  view.context = self.context;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}

@end



