//
//  ScoreLayer.m
//  Sk8 or Die
//
//  Created by Thomas ROBIN on 12/07/13.
//  Copyright 2013 Thomas ROBIN. All rights reserved.
//

#import "ScoreLayer.h"


@implementation ScoreLayer

- (id) init
{
    if ((self = [super init])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        self.label = [CCLabelTTF labelWithString:@"00000m" fontName:@"Marker Felt" fontSize:20];
        _label.position = ccp(winSize.width*0.9, winSize.height*0.95);
        _label.color = ccc3(0,0,0);
        [self addChild:_label];
    }
    return self;
}

@end
