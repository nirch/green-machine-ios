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
        [dict setObject:[NSArray arrayWithObjects:@"greenmachine.credits.5",@"greenmachine.credits.30",@"greenmachine.credits.60",@"greenmachine.credits.100",nil] forKey:@"productids"];
        [dict setObject:[NSArray arrayWithObjects:@"5", @"30", @"60", @"100", nil] forKey:@"productcredits"];
    }
    

    self.formats = @[ @"close up port %d", @"head&shoulders port %d", @"head&chest port %d", @"torso port %d", @"As port %d"];
    self.contours = @[ @"close+up+360", @"head+and+shoulders+360", @"head+and+chest+360", @"torso+360", @"american+shot+360",@"knees+up+360"];
    
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
        [self.backgrounds addObject:background];
        [self synchronize];
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


-(BOOL) supports:(NSString *) topic {
    return ( [[dict allKeys] indexOfObject:topic] != NSNotFound);
}

-(id) valueForKey:(NSString *)key {
    return [dict valueForKey:key];
}

- (id)objectForKey:(NSString *)defaultName {
    return [dict objectForKey:defaultName];
}
- (void)setObject:(id)value forKey:(NSString *)defaultName {
    [dict setObject:value forKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [dict removeObjectForKey:defaultName];
}

- (NSString *)stringForKey:(NSString *)defaultName {
    return [dict valueForKey:defaultName];
}
- (NSArray *)arrayForKey:(NSString *)defaultName {
    return [dict objectForKey:defaultName];
}
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return [dict valueForKey:defaultName];
}
- (NSData *)dataForKey:(NSString *)defaultName {
    return [dict objectForKey:defaultName];
}
- (NSInteger)integerForKey:(NSString *)defaultName {
    return [[dict objectForKey:defaultName] intValue];
}
- (float)floatForKey:(NSString *)defaultName {
    return [[dict objectForKey:defaultName] floatValue];
}
- (double)doubleForKey:(NSString *)defaultName {
    return [[dict objectForKey:defaultName] doubleValue];
}
- (BOOL)boolForKey:(NSString *)defaultName {
    return [[dict objectForKey:defaultName] boolValue];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [dict setObject:[NSNumber numberWithInt:value] forKey:defaultName];
}
- (void)setFloat:(float)value forKey:(NSString *)defaultName {
    [dict setObject:[NSNumber numberWithFloat:value] forKey:defaultName];
}
- (void)setDouble:(double)value forKey:(NSString *)defaultName {
    [dict setObject:[NSNumber numberWithDouble:value] forKey:defaultName];
}
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [dict setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}


@end
