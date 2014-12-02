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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSURL *url = [NSURL URLWithString:@"http://www.inboundsdiscgolf.com/content/?page_id=431"];
    NSData *flightDataPage = [NSData dataWithContentsOfURL:url];
    TFHpple *flightPathDataParser = [TFHpple hppleWithHTMLData:flightDataPage];
    
    NSString *queryStr = @"//table[@id='inFlightGuide']/tbody/td"; // Getting all the td tags
    
    NSArray *tableRows = [flightPathDataParser searchWithXPathQuery:queryStr];
    
    int numberOfElementsPerDisc = 7;
    int counter = 0;
    Disc *currentDisc;
    
    NSMutableArray *discCatalog = [NSMutableArray array];
    for(TFHppleElement *element in tableRows){
        
        if(counter > numberOfElementsPerDisc){
            counter = 0;
        }
    
        if(counter == 0){
            currentDisc = [[Disc alloc] init];
            [discCatalog addObject:currentDisc];
        }
        
        NSString *metadata = [[element firstChild] content];
        
        switch (counter) {
            case 0:
                currentDisc.name = metadata;
                break;
            case 1:
                currentDisc.manufacturer = metadata;
                break;
            case 2:
                currentDisc.type = metadata;
                break;
            case 3:
                currentDisc.distance = metadata;
                break;
            case 4:
                currentDisc.hst = metadata;
                break;
            case 5:
                currentDisc.lsf = metadata;
                break;
            case 6:
                currentDisc.net = metadata;
                break;
            case 7:
                // Extract the id
                currentDisc.imageId = [self extractImageIdFromElement:element];
                
                
                break;
            default:
                break;
        }
        
        counter++;
        
    }
    
    for(Disc *d in discCatalog){
        NSLog(@"Name of disc:%@ with id:%@",d.name,d.imageId);
    }
    
    NSLog(@"Number of discs:%i",(unsigned long)[discCatalog count]);
    
    //http://www.inboundsdiscgolf.com/content/WebCharts/8994436.png
    
    [self processDiscs:discCatalog];
    
    
    
    return YES;
}

// Note: Very fragile.
- (NSString *) extractImageIdFromElement:(TFHppleElement *)element{
    
    NSArray *children = [element children];
    TFHppleElement *targetChild = children[1];
    NSDictionary *attribs = [targetChild attributes];
    NSString *imgId = attribs[@"href"];
    
    if(imgId){
        imgId = [imgId componentsSeparatedByString:@","][1];
        imgId = [imgId substringWithRange:NSMakeRange(1, 7)];
    }
    
    return imgId;
}

- (void) processDiscs:(NSArray *) discs{
    
    for(Disc *d in discs){
        NSString *stringURL = [NSString stringWithFormat:@"http://www.inboundsdiscgolf.com/content/WebCharts/%@.png",d.imageId];
        NSURL  *url = [NSURL URLWithString:stringURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        if(urlData){
            UIImage *image = [UIImage imageWithData:urlData];
            NSLog(@"I haz the image");
        }
    }
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
