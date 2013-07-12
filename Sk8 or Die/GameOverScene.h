//
//  GameOverScene.h
//  Sk8 or Die
//
//  Created by Thomas ROBIN on 12/07/13.
//  Copyright 2013 Thomas ROBIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayer {
    CGSize winSize;
}

- (void)createMenuLabels;
- (void)restart;
- (void)menu;

@end



//scene
@interface GameOverScene : CCScene

@property (nonatomic, retain) GameOverLayer *layer;

@end