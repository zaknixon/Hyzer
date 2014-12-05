//
//  Disc.m
//  Hyzer
//
//  Created by Zak Nixon on 12/1/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "Disc.h"

@implementation Disc

- (NSString *)description{
    NSString *d = [NSString stringWithFormat:@"%@-%@",self.manufacturer,self.name];
    return d;
}
@end
