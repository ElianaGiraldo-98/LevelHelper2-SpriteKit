//
//  LHGravityArea.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

/**
 LHGravityArea class is used to load a gravity area object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHGravityArea : SKNode <LHNodeProtocol>

+(instancetype)gravityAreaWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt;

/**
 Returns the unique identifier of this node.
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
 Returns the size as defined in LevelHelper.
 */
-(CGSize)size;

/**
 Returns whether or not this gravity area is a radial.
 */
-(BOOL)isRadial;

/**
 Returns the direction in which the force is applied.
 */
-(CGPoint)direction;

/**
 Returns the force of this gravity area.
 */
-(float)force;
@end