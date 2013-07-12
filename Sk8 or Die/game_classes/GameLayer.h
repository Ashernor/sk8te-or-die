//
//  GameLayer.h
//  Sk8 or Die
//
//  Created by Thomas ROBIN on 12/07/13.
//  Copyright 2013 Thomas ROBIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MovingPlatform.h"
#import "ScoreLayer.h"

@interface GameLayer : CCLayer {
    MovingPlatform *platform;
    ScoreLayer *scoreLayer;
    CCSpriteBatchNode *_batchNode;
    CCSprite *_hero;
    
    CGSize winSize;
    CGPoint heroRunningPosition;
	CGPoint jumpVelocity;
    
    BOOL isJumpingAnimation;
    
    int _nextEnemy;
    CGPoint firstTouch;
    CGPoint lastTouch;
    
    float platformHeadSize;
}

@property (nonatomic, retain) CCSprite *hero;
@property (nonatomic, retain) CCAction *runAction;
@property CGPoint heroRunningPosition;
@property CGPoint jumpVelocity;
@property BOOL isJumping;
@property BOOL isGap;
@property int score;

+(CCScene *) scene;

@end
