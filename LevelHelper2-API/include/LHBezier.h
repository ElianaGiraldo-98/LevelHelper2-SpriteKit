//
//  LHBezier.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"

/**
 LHBezier class is used to load and display a bezier from a level file.
 Users can retrieve a bezier objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHBezier : SKShapeNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)bezierNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt;


/**
 Returns the unique identifier of this bezier node.
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
 Returns the size of the bezier node by computing the bounding box of the points.
 */
-(CGSize)size;

@end