//
//  MovingPlatform.h
//  Sk8 or Die
//
//  Created by Thomas ROBIN on 12/07/13.
//  Copyright 2013 Thomas ROBIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MovingPlatform : CCSprite {
    CGSize winSize;
    CCArray *_platforms1;
    CCArray *_platforms2;
    CCArray *_platforms3;
    
    CCArray *_imagePlatformLeft;
    CCArray *_imagePlatformMid;
    CCArray *_imagePlatformRight;
    
    int _nextPlatformLeft;
    int _nextPlatformMid;
    int _nextPlatformRight;
    
    BOOL isPlatform1InAction;
    BOOL isPlatform2InAction;
    BOOL isPlatform3InAction;
    BOOL isGap;
    
    //important settings
    BOOL isPaused;
    float platformSpeed;
    int maximumPlatformIteration;
    int numPlatformArray;
    //images variables
    NSString *leftImageName;
    NSString *middleImageName;
    NSString *rightImageName;
    
    CGPoint targetCoordinate;
    CGPoint returnCoordinate;
    CGPoint pointZero;
    
}

@property BOOL isPaused;
@property double platformWidth;
@property double platformHeight;
@property float platformSpeed;
@property int maximumPlatformIteration;
@property int numPlatformArray;
@property CGFloat targetCoorX;
@property CGPoint targetCoordinate;
@property (nonatomic, retain) NSString *leftImageName;
@property (nonatomic, retain) NSString *middleImageName;
@property (nonatomic, retain) NSString *rightImageName;

- (id)initWithSpeed:(float)speed andPause:(BOOL)pause andImages:(CCArray*)images;
- (void)paused:(BOOL)yesno;
- (CGPoint)getYCoordinateAt:(CGPoint)coorX;

@end
