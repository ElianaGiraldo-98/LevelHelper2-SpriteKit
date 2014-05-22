//
//  LHPrismaticJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHPrismaticJointNode class is used to load a LevelHelper prismatic joint.
 The equivalent in SpriteKit is a SKPhysicsJointSliding joint object, which is a wrapper over Box2d b2PrismaticJoint.
 */

@interface LHPrismaticJointNode : SKNode <LHNodeProtocol>

+(instancetype)prismaticJointNodeWithDictionary:(NSDictionary*)dict
                                         parent:(SKNode*)prnt;

/**
 Returns the joint connection point. In scene coordinates.
 */
-(CGPoint)anchor;

/**
 Returns the unique identifier of this joint node.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
-(NSArray*)tags;

/**
 Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;


/**
 Returns the actual SpriteKit joint that connects the two bodies together.
 */
-(SKPhysicsJointSliding*)joint;

/**
 Returns the axis vector that defines the direction that the joint is allowed to slide.
 */
-(CGPoint)axis;

/**
 A Boolean value that indicates whether the sliding joint is restricted so that the objects may only slide a finite distance from the initial anchor point.
 */
-(BOOL)shouldEnableLimits;

/**
The smallest distance allowed for the sliding joint.
 */
-(CGFloat)lowerDistanceLimit;

/**
 The largest distance allowed for the sliding joint.
 */
-(CGFloat)upperDistanceLimit;

/**
 Removes the joint from the world.
 */
-(void)removeFromParent;
@end