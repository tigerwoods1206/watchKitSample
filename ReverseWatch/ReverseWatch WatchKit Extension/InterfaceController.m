//
//  InterfaceController.m
//  ReverseWatch WatchKit Extension
//
//  Created by YamaneRiku on 2015/01/25.
//  Copyright (c) 2015年 Riku Yamane. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *clockImage;
@property (nonatomic) NSTimer * timer;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];

}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)tick:(NSTimer*)timer
{
    // スクリーンサイズ取得
    CGSize screenSize = [[WKInterfaceDevice currentDevice] screenBounds].size;
    float cx = screenSize.width / 2.0f;
    float cy = screenSize.height / 2.0f;
    float mRad = -90.0f * M_PI / 180.0f;
    // ベースの針の長さ
    float baseR = screenSize.width / 2.0f;
    
    // 時刻を取得
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    
    // 描画
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenSize.width, screenSize.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 255.0f / 255.0f, 255.0f / 255.0f, 255.0f / 255.0f, 1.0f);
    
    // 秒針
    float rad = 2.0f * M_PI * dateComps.second / 60.0f + mRad;
    float sr = baseR; // 針の長さ
    float tx = cx + sr * cos(rad);
    float ty = cy + sr * sin(rad);
    CGContextSetLineWidth(context, 1.5f);
    CGContextMoveToPoint(context, cx, cy);
    CGContextAddLineToPoint(context, tx, ty);
    CGContextStrokePath(context);
    
    // 分針
    rad = 2.0f * M_PI * dateComps.minute / 60.0f + mRad;
    sr = baseR;
    tx = cx + sr * cos(rad);
    ty = cy + sr * sin(rad);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 3.0f);
    CGContextMoveToPoint(context, cx, cy);
    CGContextAddLineToPoint(context, tx, ty);
    CGContextStrokePath(context);
    
    // 時針
    rad = 2.0f * M_PI * dateComps.hour / 12.0f + mRad;
    sr = baseR * 0.6f;
    tx = cx + sr * cos(rad);
    ty = cy + sr * sin(rad);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 5.0f);
    CGContextMoveToPoint(context, cx, cy);
    CGContextAddLineToPoint(context, tx, ty);
    CGContextStrokePath(context);
    
    // 色々描画したのをUIImageに変換
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 左右反転
    img = [self reverseImage:img];
    
    // 画像をセットする
    [self.clockImage setImage:img];
}

- (UIImage *) reverseImage :(UIImage *) src
{
    CGImageRef imgRef = [src CGImage];
    
    UIGraphicsBeginImageContext(src.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM( context, src.size.width,src.size.height);
    CGContextScaleCTM( context, -1.0, -1.0);
    CGContextDrawImage( context, CGRectMake( 0, 0,src.size.width, src.size.height), imgRef);
    UIImage *retImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImg;
}

@end



