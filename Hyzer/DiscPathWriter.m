//
//  DiscPathWriter.m
//  Hyzer
//
//  Created by Zak Nixon on 12/8/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//  ddd

#import "DiscPathWriter.h"

@implementation DiscPathWriter

- (void) writeDisc:(Disc *) disc withCoordinates:(NSArray *) coordinates toPath:(NSString *) path{
    
    NSLog(@"Disc information was written to:%@",path);
    
    NSError *error;
    
    NSMutableDictionary *discInformation = [NSMutableDictionary dictionary];
    
    if(!disc.name) disc.name = @"";
    
    discInformation[@"name"] = disc.name;
    discInformation[@"manufacturer"] = disc.manufacturer;
    discInformation[@"coordinates"] = coordinates;

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:discInformation
                                                       options:kNilOptions
                                                         error:&error];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:path];
    [jsonData writeToFile:appFile atomically:YES];
    NSLog(@"Written to:%@",appFile);
}

@end
