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
#define IMAGE_URL @"http://www.inboundsdiscgolf.com/content/WebCharts/%@.png"

@interface DiscInformationRetriever()
@property (nonatomic,strong) NSMutableArray *discCatalog;

@end
@implementation DiscInformationRetriever

- (void)retrieveDiscsAndPerformBlock:(void (^)(NSArray *))completion{
    
    NSURL *url = [NSURL URLWithString:MAIN_PAGE_URL];
    NSData *flightDataPage = [NSData dataWithContentsOfURL:url];
    TFHpple *flightPathDataParser = [TFHpple hppleWithHTMLData:flightDataPage];
    
    NSArray *tableRows = [flightPathDataParser searchWithXPathQuery:DISC_QUERY_XPATH];
    
    int numberOfElementsPerDisc = 7;
    int counter = 0;
    Disc *currentDisc;
    
    self.discCatalog = [NSMutableArray array];
    for(TFHppleElement *element in tableRows){
        
        if(counter > numberOfElementsPerDisc){
            counter = 0;
        }
        
        if(counter == 0){
            currentDisc = [[Disc alloc] init];
            [self.discCatalog addObject:currentDisc];
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
    
    for(Disc *d in self.discCatalog){
        
        NSString *fileName = [NSString stringWithFormat:@"%@-%@.png",d.manufacturer,d.name];
        
        // Figuring out if the file already exists in the documents directory.
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* foofile = [documentsPath stringByAppendingPathComponent:fileName];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
        
        if(!fileExists){
            NSString *stringURL = [NSString stringWithFormat:IMAGE_URL,d.imageId];
            NSURL  *url = [NSURL URLWithString:stringURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            d.flightPathImage = [UIImage imageWithData:urlData];
            [urlData writeToFile:foofile atomically:YES];
            NSLog(@"Data pulled for %@-%@",d.manufacturer,d.name);
        }
    }
    
    completion(self.discCatalog);
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
