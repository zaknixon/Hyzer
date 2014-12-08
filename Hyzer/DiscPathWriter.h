//
//  DiscPathWriter.h
//  Hyzer
//
//  Created by Zak Nixon on 12/8/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Disc.h"

@interface DiscPathWriter : NSObject

- (void) writeDisc:(Disc *) disc withCoordinates:(NSArray *) coordinates toPath:(NSString *) path;

@end
