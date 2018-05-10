//
//  CustomSlider.m
//  Leaderboard
//
//  Created by Alex on 03/05/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint touchLocation = [touch locationInView:self];
    CGFloat value = self.minimumValue + (self.maximumValue - self.minimumValue) *
    ((touchLocation.x - self.currentThumbImage.size.width/2) /
     (self.frame.size.width-self.currentThumbImage.size.width));
    
    [UIView animateWithDuration:0.5 animations:^{
        [self setValue:value animated:YES];
    }];
    
    return YES;
}

@end
