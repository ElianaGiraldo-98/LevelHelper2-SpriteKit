//
//  LHNodeAnimationProtocol.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LHAnimation;

/**
 LevelHelper 2 nodes that can be animated conform to this protocol.
 */

@protocol LHNodeAnimationProtocol <NSObject>

@required

/**
 Set the active animation on a node.
 @param animation The animation that is about to get activated.
 */
-(void)setActiveAnimation:(LHAnimation*)animation;

/**
 Set position on the node controlled by the animation.
 @param point A point value.
 */
-(void)setPosition:(CGPoint)point;

/**
 Set rotation on the node controlled by the animation.
 @param radians A rotation value in radians.
 */
-(void)setZRotation:(float)radians;

/**
Set x scale on the node controlled by the animation.
@param xScale A scale value for the x axis.
*/
-(void)setXScale:(float)xScale;

/**
 Set y scale on the node controlled by the animation.
 @param yScale A scale value for the y axis.
 */
-(void)setYScale:(float)yScale;

/**
 Set opacity on the node controlled by the animation.
 @param opacity A opacity value between 0 and 1.
 */
-(void)setAlpha:(float)opacity;

@end