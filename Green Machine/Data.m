//
//  Data.m
//  Green Machine
//
//  Created by Eyal Shpits on 8/18/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "Data.h"
#import "DataBackground.h"


@implementation Data
+(Data *) shared {
	static Data  *inst = nil;
	if ( inst ) {
		return inst ;
	}
	inst = [[Data alloc] init];
	return inst;
}

-(void) reset {
    self.backgrounds = [NSMutableArray array];
    [self.backgrounds removeAllObjects];
    self.currentBackground = [NSNumber numberWithInt:0];
    self.currentFormat = [NSNumber numberWithInt:1];
    self.resolution = [NSNumber numberWithInt:360];
    self.credits = [NSNumber numberWithInt:8];
    
    NSDictionary * dictSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
    if ( dictSaved!= nil && [dictSaved count] > 0 ) {
        dict = [[NSMutableDictionary alloc]initWithDictionary:dictSaved];
        
        NSData *encodedObject = [dict objectForKey:@"backgrounds"];
        NSArray *backgrounds = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        if ( backgrounds ) {
            [self.backgrounds addObjectsFromArray:backgrounds];
        }
    }
    else {
        dict = [NSMutableDictionary dictionary];
        self.formats = @[ @"close up port %d", @"head&shoulders port %d", @"head&chest port %d", @"torso port %d", @"As port %d"];
        NSArray * isLocked = @[ @(false), @(true),@(true),@(true),@(true),@(true),@(true),@(true),@(true),@(true),
                                @(true),@(true),@(true),@(true),@(true),@(true),@(true),@(true),@(true),@(true),
                                @(true),@(true),@(true),@(true)];
        NSArray * cost = @[ @(0), @(2),@(2),@(5),@(5),@(5),@(5),@(10),@(10),@(10),
                                @(20),@(20),@(20),@(20),@(20),@(20),@(20),@(20),@(20),@(20),
                                @(100),@(100),@(100),@(100)];

        for ( int index = 0; index < 24; index ++ ) {
            DataBackground * background = [[DataBackground alloc]init:nil];
            background.isLocked = [isLocked objectAtIndex:index];
            background.cost = [cost objectAtIndex:index];
//            background.isLocked = [NSNumber numberWithBool:false];
            [self.backgrounds addObject:background];
        }
        

    }
}


- (BOOL)synchronize {
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.backgrounds];
    [dict setObject:myEncodedObject forKey:@"backgrounds"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"data"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) init {
	self = [super init];
	if ( self ) {
        [self reset];
    }
	return self;
}

+(BOOL) isRatine {
    static int result = -1;
    if ( result == -1 ) {
        if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
            CGFloat scale = [[UIScreen mainScreen] scale];
            result =  (scale > 1.0);
        }
    }
    return result;
}


@end
