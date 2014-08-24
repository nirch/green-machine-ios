//
//  DataComixPage.h
//  Comics Studio
//
//  Created by Eyal Shpits on 8/9/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBackground : NSObject


-(id) init:(NSDictionary * ) dict;

@property ( retain, nonatomic ) NSString * format;
@property ( retain, nonatomic ) NSNumber * isLocked;
@property ( retain, nonatomic ) NSNumber * cost;

@end
