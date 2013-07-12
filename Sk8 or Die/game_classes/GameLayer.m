//
//  GameLayer.m
//  Sk8 or Die
//
//  Created by Thomas ROBIN on 12/07/13.
//  Copyright 2013 Thomas ROBIN. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"

#define kInitialSpeed 4
#define kTagStepDistance 0
#define kJumpHigh 22
#define kJumpShort 13
#define kGravityFactor -1
#define kPlatformHeadSize 145
#define kDifficultySpeed 0.25
#define kDifficultyScore 100
#define kInitialEnemies 10

@interface GameLayer (private)
- (void) initBackground;
- (void) initPlatform;
- (void) initEnemy;
- (void) gameOver;
- (void) createHero;
- (void) changeHeroImageDuringJump;
- (void) initScore;
- (void) updateScore;
- (void) increaseDifficulty;
@end

@implementation GameLayer

@synthesize isJumping;
@synthesize isGap;
@synthesize jumpVelocity;
@synthesize heroRunningPosition;


+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
    return scene;
}

-(id) init
{
    platformHeadSize = kPlatformHeadSize;
	if( (self=[super init])) {
        self.touchEnabled = YES;
		isJumping = NO;
        isGap = NO;
        isJumpingAnimation = NO;
        jumpVelocity = CGPointZero;
        
        winSize = [CCDirector sharedDirector].winSize;
        heroRunningPosition = ccp(winSize.width * 0.25, winSize.height * 0.5 - kPlatformHeadSize + 6);
        
        [self initPlatform];
        [self createHero];
        [self initBackground];
        [self initScore];
	}
	return self;
}

- (void) initPlatform
{
    CCArray *images = [[CCArray alloc] initWithCapacity:3];
    [images addObject:@"platform-left.png"];
    [images addObject:@"platform.png"];
    [images addObject:@"platform-right.png"];
    
    platform = [[MovingPlatform alloc] initWithSpeed:kInitialSpeed andPause:NO andImages:images];
    
    [self addChild:platform z:0];
    [self scheduleUpdate];
}


- (void) initBackground {
    CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointZero;
    [self addChild:background z:-1];
}


-(void) createHero
{
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"skater.png"];
    [self addChild:_batchNode];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"skater.plist"];
    
    //gather list of frames
    NSMutableArray *runAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 7; ++i) {
        [runAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"skater-%d.png", i]]];
    }
    
    //create sprite and run the hero
    self.hero = [CCSprite spriteWithSpriteFrameName:@"skater-1.png"];
    _hero.anchorPoint = CGPointZero;
    _hero.position = self.heroRunningPosition;
    
    //create the animation object
    CCAnimation *runAnim = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.1f];
    runAnim.restoreOriginalFrame = YES;
    self.runAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:runAnim]];
    
    [_hero runAction:_runAction];
    [_batchNode addChild:_hero z:0];
}




-(void) update:(ccTime)dt
{
    CGPoint returnedCoordinate = [platform getYCoordinateAt:heroRunningPosition];
    if (heroRunningPosition.y != returnedCoordinate.y) {
        heroRunningPosition = ccp(heroRunningPosition.x, returnedCoordinate.y - platformHeadSize);
    }
    
    //falling between gap
    if (returnedCoordinate.x <= 0 && returnedCoordinate.y <= 0) {
        isGap = YES;
        heroRunningPosition = ccp(heroRunningPosition.x, -_hero.textureRect.size.height);
        if (isJumping == NO) {
            jumpVelocity = ccpAdd(jumpVelocity, ccp(0,kGravityFactor));
            _hero.position = ccpAdd(_hero.position, jumpVelocity);
            if (_hero.position.y < heroRunningPosition.y) {
                [self gameOver];
            }
        }
    } else {
        isGap = NO;
    }
    
    if (_hero.position.y < heroRunningPosition.y) {
        if (jumpVelocity.y >= 0) {
            _hero.position = ccp(heroRunningPosition.x - _hero.textureRect.size.width*2,
                                 heroRunningPosition.y);
        }
        jumpVelocity = ccpAdd(jumpVelocity, ccp(0,kGravityFactor));
        _hero.position = ccpAdd(_hero.position, jumpVelocity);
        [platform paused:YES];
        [_hero stopAllActions];
        if (_hero.position.y < -winSize.height) {
            [self gameOver];
        }
    }
}



-(void)jump:(ccTime)delta
{
	if (isJumping == YES) {
        if (jumpVelocity.y < 0 &&
            _hero.position.y > heroRunningPosition.y &&
            _hero.position.y < heroRunningPosition.y + _hero.textureRect.size.height) {
            //hero landed
            _hero.position = heroRunningPosition;
            jumpVelocity = CGPointZero;
            
            [self unschedule:@selector(jump:)];
            isJumping = NO;
            isJumpingAnimation = NO;
            [_hero stopAllActions];
            //NSLog(@"run action.");
            if (_hero.position.y <= heroRunningPosition.y) [_hero runAction:_runAction];
            
        } else {
			//make the hero jump with gravity=-1
            jumpVelocity = ccpAdd(jumpVelocity, ccp(0,kGravityFactor));
            _hero.position = ccpAdd(_hero.position, jumpVelocity);
            //change jumping image
            //[_hero stopAllActions];
            //[self changeHeroImageDuringJump];
		}
	}
}

- (void) updateScore:(ccTime)dt
{
    _score += 1;
    [scoreLayer.label setString:[NSString stringWithFormat:@"%05dm", _score]];
    
    //increase difficulty every 200m run
    if (_score % kDifficultyScore == 0) {
        [self increaseDifficulty];
    }
}


-(void)changeHeroImageDuringJump
{
	/*[_hero setTextureRect:[[CCSpriteFrameCache sharedSpriteFrameCache]
     spriteFrameByName:@"skater-jump1.png"].rect];*/
    
    //gather list of frames
    if (!isJumpingAnimation){
        isJumpingAnimation = YES;
        NSMutableArray *runAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 10; ++i) {
            [runAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"skater-jump%d.png", i]]];
        }
        
        
        //create the animation object
        CCAnimation *jumpAnimation = [CCAnimation animationWithSpriteFrames:runAnimFrames delay:0.1f];
        jumpAnimation.restoreOriginalFrame = YES;
        CCAction *jump = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:jumpAnimation]];
        jump.tag = 89;
        [_hero stopAllActions];
        [_hero cleanup];
        [_hero runAction:jump];
    }
    
}

- (void) increaseDifficulty
{
    platform.platformSpeed += kDifficultySpeed;
}


//register touch action
-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Swipe
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    firstTouch = location;
    
    if (isJumping == NO && isGap == NO & firstTouch.x < 160) {
        [self changeHeroImageDuringJump];
        isJumping = YES;
        jumpVelocity = ccp(0, kJumpHigh);
        [self schedule:@selector(jump:) interval:(1.0 / 60.0)];
    }
    
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    if (jumpVelocity.y > kJumpShort) {
		jumpVelocity = ccp(0, kJumpShort);
	}
    
    //swipe
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    
    //Check if the swipe is a left swipe and long enough
    if (firstTouch.y > lastTouch.y && swipeLength > 40 && !isJumping) {
        //NSLog(@"swipe from up to down");
        [platform wentOnSecondLane];
        platformHeadSize = 170;
        CGPoint returnedCoordinate = [platform getYCoordinateAt:heroRunningPosition];
        heroRunningPosition = ccp(heroRunningPosition.x, returnedCoordinate.y - platformHeadSize);
        _hero.position = heroRunningPosition;
    }else if (firstTouch.y < lastTouch.y && swipeLength > 40 && !isJumping){
        //NSLog(@"swipe from down to up");
        [platform wentOnFirstLane];
        platformHeadSize = 140;
        CGPoint returnedCoordinate = [platform getYCoordinateAt:heroRunningPosition];
        heroRunningPosition = ccp(heroRunningPosition.x, returnedCoordinate.y - platformHeadSize);
        _hero.position = heroRunningPosition;
    }else{
    }
}

- (void)gameOver {
    _hero.visible = NO;
    [platform paused:YES];
    [_hero stopAllActions];
    [self unscheduleAllSelectors];
    
    GameOverScene *gameOverScene = [GameOverScene node];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void) initScore
{
    _score = 0;
    scoreLayer = [ScoreLayer node];
    [scoreLayer.label setString:[NSString stringWithFormat:@"%05dm", _score]];
    [self addChild:scoreLayer];
    
    [self schedule:@selector(updateScore:) interval:(5.0 / 60.0)];
}



@end
