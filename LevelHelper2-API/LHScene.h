//
//  LHScene.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

#import "LHConfig.h"


@class LHScene;
@class LHGameWorldNode;
@class LHUINode;
@class LHBackUINode;
@class LHAnimation;


#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#endif
#endif //LH_USE_BOX2D

@protocol LHCollisionHandlingProtocol <NSObject>

@required
#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode*)a
                               andNodeB:(SKNode*)b;

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b;

#else //spritekit

- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)didEndContact:(SKPhysicsContact *)contact;

#endif

@end


@protocol LHAnimationNotificationsProtocol <NSObject>

@required
-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;

@end



#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

/**
 LHScene class is used to load a level file into SpriteKit engine.
 End users will have to subclass this class in order to add they're game logic.
 */
@interface LHScene : SKScene <LHNodeProtocol>

#if TARGET_OS_IPHONE
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;
#else
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size;
#endif

/**
 Returns a SKTextureAtlas object that was previously loaded or a new one.
 @param atlasPath The path of the atlas (usually a sprite name)
 @return A texture atlas or nil if not found.
 */
-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath;

/**
 Returns a SKTexture object that was previously loaded or a new one.
 @param imagePath The path of the image file.
 @return A texture object or nil if image could not be found.
 */
-(SKTexture*)textureWithImagePath:(NSString*)imagePath;


/**
 Returns the game world rectangle or CGRectZero if the game world rectangle is not set in the level file.
 */
-(CGRect)gameWorldRect;


/**
 Returns the game world node. All children of this node will move with the camera. For UI elements use the uiNode.
 */
-(LHGameWorldNode*)gameWorldNode;

/**
 Returns the Front UI node. All children of this node will NOT move with the camera.
 */
-(LHUINode*)uiNode;

/**
 Returns the Back UI node. All children of this node will NOT move with the camera.
 */

-(LHBackUINode*)backUINode;

/**
 Returns the relative plist path that was used to load this scene information.
 */
-(NSString*)relativePath;

#pragma mark- ANIMATION HANDLING

/**
 Set a animation notifications delegate. Will only work if you do not overwrite the animation notifications methods when subclassing LHScene.
 If you delete the delegate object make sure you nullify the animation notifications delegate.
 */
-(void)setAnimationNotificationsDelegate:(id<LHAnimationNotificationsProtocol>)del;

-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;


#pragma mark- COLLISION HANDLING

/**
 Set a collision handling delegate. Will only work if you do not overwrite collision handling methods when subclassing LHScene.
 If you delete the delegate object make sure you nullify the collision handling delegate.
 */
-(void)setCollisionHandlingDelegate:(id<LHCollisionHandlingProtocol>)del;

#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode*)a
                               andNodeB:(SKNode*)b;

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b;

#else //spritekit

/**
 Overwrite this methods to receive collision informations. Available when using SpriteKit own physics engine. This is actually SpriteKit API.
 Consult Sprite Kit documentation for more info.
 */
- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)didEndContact:(SKPhysicsContact *)contact;
#endif


#pragma mark - Box2d Support

#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2World*)box2dWorld;

-(float)ptm;

-(b2Vec2)metersFromPoint:(CGPoint)point;
-(CGPoint)pointFromMeters:(b2Vec2)vec;

-(float)metersFromValue:(float)val;
-(float)valueFromMeters:(float)meter;

#endif
#endif //LH_USE_BOX2D


/*Get the global gravity force.
 */
-(CGPoint)globalGravity;
/*Sets the global gravity force
 @param gravity A point representing the gravity force in x and y direction.
 */
-(void)setGlobalGravity:(CGPoint)gravity;


@end
