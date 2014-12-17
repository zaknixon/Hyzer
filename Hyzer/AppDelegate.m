//
//  AppDelegate.m
//  Hyzer
//
//  Created by Zak Nixon on 12/1/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TFHpple.h"
#import "Disc.h"
#import "DiscInformationRetriever.h"
#import "DiscImageTransformer.h"
#import "DiscPathLocator.h"
#import "DiscPathWriter.h"

@interface AppDelegate ()

@end

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

@implementation AppDelegate

// BUMP FOR GITHUB.

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    DiscInformationRetriever *retriever = [[DiscInformationRetriever alloc] init];
    [retriever retrieveDiscsAndPerformBlock:^(NSArray *discs) {
        
        DiscImageTransformer *transformer = [[DiscImageTransformer alloc] init];
        for(Disc *disc in discs){
            
            UIImage *transformedImage = [transformer transform:disc.flightPathImage];
            
            NSLog(@"Disc image was transformed for disc [%@-%@]",disc.manufacturer,disc.name);
            
            DiscPathLocator *pathLocator = [[DiscPathLocator alloc] init];
            NSArray *coordinates = [pathLocator pathContainedInImage:transformedImage];
            
            NSMutableString *output = [NSMutableString string];
            for(int i = 0; i < transformedImage.size.height;i++){
                //output = [NSMutableString string];
                for(int j = 0; j < transformedImage.size.width;j++){
                    
                    BOOL found = NO;
                    for(int k = 0; k < [coordinates count]; k++){
                        
                        NSValue *ptValue = coordinates[k];
                        CGPoint pt = [ptValue CGPointValue];
                        
                        if(pt.x == j && pt.y == i){
                            found = YES;
                            break;
                        }
                        
                    }
                    
                    if(found){
                       [output appendString:@"X"];
                    }else{
                        [output appendString:@"-"];
                    }
 
                }
                [output appendString:@"\n"];
               // NSLog(@"%@",output);
            }
            
            NSString *pathToDrawnImage = [NSString stringWithFormat:@"%@-%@-plots.txt",disc.manufacturer,disc.name];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:pathToDrawnImage];
            [output writeToFile:appFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"Wrote:%@",appFile);
            
            DiscPathWriter *pathWriter = [[DiscPathWriter alloc] init];
            NSString *path = [NSString stringWithFormat:@"%@-%@.json",disc.manufacturer,disc.name];
            
            
            NSMutableArray *coordStrs = [NSMutableArray array];
            
            for(NSValue *v in coordinates){
                CGPoint pt = [v CGPointValue];
                NSString *ptStr = [NSString stringWithFormat:@"(%2.0f,%2.0f)",pt.x,pt.y];
                [coordStrs addObject:ptStr];
            }

            [pathWriter writeDisc:disc withCoordinates:coordStrs toPath:path];

        }
    }];

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
