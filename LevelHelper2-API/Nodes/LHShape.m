//
//  LHShape.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHShape.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@implementation LHShape
{
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    
    LH_SAFE_RELEASE(_animations);
    activeAnimation = nil;

    LH_SUPER_DEALLOC();
}


+ (instancetype)shapeNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initShapeNodeWithDictionary:dict
                                                              parent:prnt]);
}

- (instancetype)initShapeNodeWithDictionary:(NSDictionary*)dict
                                     parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        [self setName:[dict objectForKey:@"name"]];
        
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];

        
        self.strokeColor = [dict colorForKey:@"colorOverlay"];
        self.fillColor = [dict colorForKey:@"colorOverlay"];
        
        float alpha = [dict floatForKey:@"alpha"];
        [self setAlpha:alpha/255.0f];
        
        float rot = [dict floatForKey:@"rotation"];
        [self setZRotation:LH_DEGREES_TO_RADIANS(-rot)];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZPosition:z];
        
        
        NSArray* points = [dict objectForKey:@"points"];
        
        CGMutablePathRef linePath = nil;
        for(NSDictionary* pointDict in points)
        {
            CGPoint vPoint = [pointDict pointForKey:@"point"];
            if(!linePath){
                linePath = CGPathCreateMutable();
                CGPathMoveToPoint(linePath, nil, vPoint.x, -vPoint.y);
            }
            else{
                CGPathAddLineToPoint(linePath, nil, vPoint.x, -vPoint.y);
            }
        }

        if(linePath){
            CGPathCloseSubpath(linePath);
            self.path = linePath;
            CGPathRelease(linePath);
        }

        
        [self loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"] nodeDict:dict];
        
        
        //scale must be set after loading the physic info or else spritekit will not resize the body
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setXScale:scl.x];
        [self setYScale:scl.y];
        
        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
                SKNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                            parent:self];
#pragma unused (node)
            }
        }
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];
    }
    
    return self;
}

-(void)loadPhysicsFromDict:(NSDictionary*)dict nodeDict:(NSDictionary*)nodedict{
    
    if(!dict)return;
    
    int shape = [dict intForKey:@"shape"];
    
    NSArray* fixturesInfo = nil;
    
    NSMutableArray* debugShapeNodes = [NSMutableArray array];

    if(shape == 0)//RECTANGLE
    {
        CGPoint offset = CGPointMake(0, 0);
        CGRect rect = CGRectMake(-self.size.width*0.5 + offset.x,
                                 -self.size.height*0.5 + offset.y,
                                 self.size.width,
                                 self.size.height);
        
        CGSize rectSize = CGSizeMake(rect.size.width,
                                     rect.size.height);

        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rectSize];
        
        if([[LHConfig sharedInstance] isDebug]){
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            debugShapeNode.path = CGPathCreateWithRect(rect,
                                                       nil);
            
            [debugShapeNodes addObject:debugShapeNode];
        }
        
    }
    else if(shape == 1)//CIRCLE
    {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width*0.5];
        if([[LHConfig sharedInstance] isDebug]){
            CGPoint offset = CGPointMake(0, 0);
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            debugShapeNode.path = CGPathCreateWithEllipseInRect(CGRectMake(-self.size.width*0.5 + offset.x,
                                                                           -self.size.width*0.5 + offset.y,
                                                                           self.size.width,
                                                                           self.size.width),
                                                                nil);
            [debugShapeNodes addObject:debugShapeNode];
        }
    }
    else if(shape == 3)//CHAIN
    {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:self.path];
        
        if([[LHConfig sharedInstance] isDebug]){
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            debugShapeNode.path = self.path;
            [debugShapeNodes addObject:debugShapeNode];
        }
    }
    else if(shape == 4)//OVAL
    {
        fixturesInfo = [dict objectForKey:@"ovalShape"];
    }
    else if(shape == 2)//POLYGON
    {
        NSArray* triangles = [nodedict objectForKey:@"triangles"];
        
        NSMutableArray* trianglebodies = [NSMutableArray array];
        
        CGMutablePathRef trianglePath = nil;
        int i = 0;
        for(NSDictionary* trDict in triangles)
        {
            CGPoint vPoint = [trDict pointForKey:@"point"];
            if(!trianglePath){
                trianglePath = CGPathCreateMutable();
                CGPathMoveToPoint(trianglePath, nil, vPoint.x, -vPoint.y);
            }
            else{
                CGPathAddLineToPoint(trianglePath, nil, vPoint.x, -vPoint.y);
            }

            ++i;
            
            if(trianglePath && i == 3){
                CGPathCloseSubpath(trianglePath);
                SKPhysicsBody* trBody = [SKPhysicsBody bodyWithPolygonFromPath:trianglePath];
                [trianglebodies addObject:trBody];
                
                if([[LHConfig sharedInstance] isDebug]){
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = trianglePath;
                    [debugShapeNodes addObject:debugShapeNode];
                }
                
                CGPathRelease(trianglePath);
                trianglePath = nil;
                i = 0;
            }
        }
        
        
#if TARGET_OS_IPHONE
        self.physicsBody = [SKPhysicsBody bodyWithBodies:trianglebodies];
#endif

    }
    
    
    if(fixturesInfo)
    {
        NSMutableArray* fixBodies = [NSMutableArray array];
        
        for(NSArray* fixPoints in fixturesInfo)
        {
            int count = (int)[fixPoints count];
            CGPoint points[count];
            
            int i = count - 1;
            for(int j = 0; j< count; ++j)
            {
                NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                CGPoint point = LHPointFromString(pointStr);
                
                //flip y for sprite kit coordinate system
                point.y =  -point.y;
                points[j] = point;
                i = i-1;
            }
            
            CGMutablePathRef fixPath = CGPathCreateMutable();
            
            bool first = true;
            for(int k = 0; k < count; ++k)
            {
                CGPoint point = points[k];
                if(first){
                    CGPathMoveToPoint(fixPath, nil, point.x, point.y);
                }
                else{
                    CGPathAddLineToPoint(fixPath, nil, point.x, point.y);
                }
                first = false;
            }
            
            CGPathCloseSubpath(fixPath);
            
            if([[LHConfig sharedInstance] isDebug]){
                SKShapeNode* debugShapeNode = [SKShapeNode node];
                debugShapeNode.path = fixPath;
                [debugShapeNodes addObject:debugShapeNode];
            }
            
            [fixBodies addObject:[SKPhysicsBody bodyWithPolygonFromPath:fixPath]];
            
            CGPathRelease(fixPath);
        }
#if TARGET_OS_IPHONE
        self.physicsBody = [SKPhysicsBody bodyWithBodies:fixBodies];
#endif
        
    }
    
    
    int type = [dict intForKey:@"type"];
    if(type == 0)//static
    {
        [self.physicsBody setDynamic:NO];
    }
    else if(type == 1)//kinematic
    {
    }
    else if(type == 2)//dynamic
    {
        [self.physicsBody setDynamic:YES];
    }
    
    
    NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
    if(fixInfo && self.physicsBody)
    {
        self.physicsBody.categoryBitMask = [fixInfo intForKey:@"category"];
        self.physicsBody.collisionBitMask = [fixInfo intForKey:@"mask"];
        
        self.physicsBody.density = [fixInfo floatForKey:@"density"];
        self.physicsBody.friction = [fixInfo floatForKey:@"friction"];
        self.physicsBody.restitution = [fixInfo floatForKey:@"restitution"];
        
        self.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
        self.physicsBody.usesPreciseCollisionDetection = [dict boolForKey:@"bullet"];
        
        if([dict intForKey:@"gravityScale"] == 0){
            self.physicsBody.affectedByGravity = NO;
        }
    }
    
    
    if([[LHConfig sharedInstance] isDebug]){
        for(SKShapeNode* debugShapeNode in debugShapeNodes)
        {
            debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.5];
            if(shape != 3){//chain
                debugShapeNode.fillColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.1];
            }
            debugShapeNode.lineWidth = 0.1;
            if(self.physicsBody.isDynamic){
                debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.5];
                debugShapeNode.fillColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.1];
            }
            [self addChild:debugShapeNode];
        }
    }
    
}


-(CGSize)size{
    return CGPathGetBoundingBox(self.path).size;
}

-(CGRect)boundingBox{
    return CGPathGetBoundingBox(self.path);
}

#pragma mark LHNodeProtocol Required

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(SKNode*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues containsAny:any forNode:self];
}


-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:self];
}

-(void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
}

#pragma mark - LHNodeAnimationProtocol
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}


@end