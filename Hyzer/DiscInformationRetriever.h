//
//  DiscInformationRetriever.h
//  Hyzer
//
//  Created by Zak Nixon on 12/5/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscInformationRetriever : NSObject

- (void) retrieveDiscsAndPerformBlock:(void(^)(NSArray *discs)) completion;

@end
