//
//  DiscInformationRetriever.m
//  Hyzer
//
//  Created by Zak Nixon on 12/5/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "DiscInformationRetriever.h"
#import "Disc.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TFHpple.h"

#define MAIN_PAGE_URL @"http://www.inboundsdiscgolf.com/content/?page_id=431"
#define DISC_QUERY_XPATH @"//table[@id='inFlightGuide']/tbody/td"

@implementation DiscInformationRetriever

- (void)retrieveDiscsAndPerformBlock:(void (^)(NSArray *))completion{
    
    NSURL *url = [NSURL URLWithString:MAIN_PAGE_URL];
    NSData *flightDataPage = [NSData dataWithContentsOfURL:url];
    TFHpple *flightPathDataParser = [TFHpple hppleWithHTMLData:flightDataPage];
    
    NSArray *tableRows = [flightPathDataParser searchWithXPathQuery:DISC_QUERY_XPATH];
    
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
                currentDisc.imageId = [self extractImageIdFromElement:element];
                break;
            default:
                break;
        }
        
        counter++;
    }
    completion(discCatalog);
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

@end
