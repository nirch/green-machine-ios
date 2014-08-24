//
//  DataComixPage.m
//  Comics Studio
//
//  Created by Eyal Shpits on 8/9/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "DataBackground.h"


@implementation DataBackground

-(id) init:(NSDictionary * ) dict {
    self = [super init];
    if ( self ) {
        self.format  = [dict objectForKey:@"format"];
        self.isLocked = [dict objectForKey:@"isLocked"];
        self.cost = [dict objectForKey:@"cost"];
    }
    return self ;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.format forKey:@"format"];
    [encoder encodeObject:self.isLocked forKey:@"isLocked"];
    [encoder encodeObject:self.cost forKey:@"cost"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.format = [decoder decodeObjectForKey:@"format"];
        self.isLocked = [decoder decodeObjectForKey:@"isLocked"];
        self.cost = [decoder decodeObjectForKey:@"cost"];
    }
    return self;
}



@end
