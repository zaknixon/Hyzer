//
//  DiscPathLocator.m
//  Hyzer
//
//  Created by Zak Nixon on 12/8/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "DiscPathLocator.h"

@implementation DiscPathLocator

- (NSArray *) pathContainedInImage:(UIImage *) pathImage{
    NSMutableArray *coordinates = [NSMutableArray array];
    
    
    for(int i = 0; i < 200; i++){
        for(int j  = 0; j < 200; j++){
            //NSValue *value = [NSValue valueWithCGPoint:CGPointMake(i,j)];
            NSString *coordinate = [NSString stringWithFormat:@"(%i,%i)",i,j];
            [coordinates addObject:coordinate];
        }
    }
    
    
    return coordinates;
}

@end
