//
//  Data.h
//  Green Machine
//
//  Created by Eyal Shpits on 8/18/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSUserDefaults   {
@private
    
    NSMutableDictionary * dict;
}

+(Data *) shared;
+(BOOL) isRatine;

@property ( nonatomic, retain) NSNumber * credits;

@property ( nonatomic, retain) NSArray * formats;
@property ( nonatomic, retain) NSArray * contours;
@property ( nonatomic, retain) NSNumber * currentFormat;
@property ( nonatomic, retain) NSMutableArray * backgrounds;
@property ( nonatomic, retain) NSNumber * currentBackground;
@property ( nonatomic, retain) NSNumber * resolution;
@end
