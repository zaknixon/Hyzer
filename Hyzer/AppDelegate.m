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

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSArray *supportedFilters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    for (CIFilter *filter in supportedFilters) {
        NSString *string = [NSString stringWithFormat:@"%@",[[CIFilter filterWithName:(NSString *)filter] inputKeys]];
        NSLog(@"%@ %@", filter, string);
    }
    
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
            //NSLog(@"I haz the image");
            
            //NSData *data = [[NSData alloc] initWithBytes:saves length:4];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileName = [NSString stringWithFormat:@"%@-%@.png",d.manufacturer,d.name];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
            [urlData writeToFile:appFile atomically:YES];
            
            NSLog(@"Written to:%@",appFile);
            
            CIFilter *exposure = [CIFilter filterWithName:@"CIExposureAdjust"];
            [exposure setDefaults];
            [exposure setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
            [exposure setValue:@0.9 forKey:@"inputEV"];
            CIImage *result = [exposure valueForKey: kCIOutputImageKey];
            
            
//            Adapts the reference white point for an image.
//                
//                Localized Display Name
//                Temperature and Tint
//                
//                Parameters
//                inputImage
//                A CIImage object whose display name is Image.
//                inputNeutral
//                A CIVector object whose attribute type is CIAttributeTypeOffset and whose display name is Neutral.
//                
//                Default value: [6500, 0]
//                inputTargetNeutral	
//                A CIVector object whose attribute type is CIAttributeTypeOffset and whose display name is TargetNeutral
//                
//                Default value: [6500, 0]
//            CIImage *ciImage = [[CIImage alloc] initWithImage:image];
//            CIFilter *tempAndTint = [CIFilter filterWithName:@"CITemperatureAndTint"];
//            [tempAndTint setDefaults];
//            [tempAndTint setValue:ciImage forKey:kCIInputImageKey];
//            [tempAndTint setValue:[CIVector vectorWithX:6000 Y:0] forKey:@"inputNeutral"];
//            result = [tempAndTint valueForKey: kCIOutputImageKey];
            //image = [[UIImage alloc] initWithCIImage:result];
            
            
//            float intensity= 0.5;
            //ciImage = [[CIImage alloc] initWithImage:image];
            for(int i = 0; i < 45; i++){
            CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
            [lighten setDefaults];
            [lighten setValue:result forKey:kCIInputImageKey];
//            //[lighten setValue:@(1 - intensity) forKey:@"inputBrightness"];
            //[lighten setValue:@0.2 forKey:@"inputSaturation"];
            [lighten setValue:@1.3 forKey:@"inputContrast"];
            result = [lighten valueForKey: kCIOutputImageKey];
            
            }

            for(int i = 0; i < 15; i++){
                CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
                [sepia setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
                [sepia setValue:@(0.75) forKey:@"inputIntensity"];
                //result = [sepia valueForKey: kCIOutputImageKey];
            }
            
            image = [UIImage imageWithCIImage:result];

            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGRect cropRect = CGRectMake(27,20,newImage.size.width-49,newImage.size.height-45);
            CGImageRef cgImage = [newImage CGImage];
            CGImageRef imageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
            // or use the UIImage wherever you like
            newImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            NSData *imageData = UIImagePNGRepresentation(newImage);
            fileName = [NSString stringWithFormat:@"%@-%@44.png",d.manufacturer,d.name];
            appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
            [imageData writeToFile:appFile atomically:YES];
            NSLog(@"Written to:%@",appFile);
            
            [self logPixelsOfImage:newImage];
            
        }
    }
}

- (void)logPixelsOfImage:(UIImage*)image {
    // 1. Get pixels of image
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * pixels;
    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
    
    // 2. Iterate and log!
    NSLog(@"Brightness of image:");
    UInt32 * currentPixel = pixels;
    NSUInteger y =0;
    for (NSUInteger j = 0; j < height; j++) {
        
        NSUInteger startX = 0,endX = 0,finalX = 0;
        UInt32 previousColor;
        y = 0;
        for (NSUInteger i = 0; i < width; i++) {
            UInt32 color = *currentPixel;
            
            if(finalX != 0){
                startX = 0; endX = 0;finalX = 0;
            }
            
            float brightness = (R(color)+G(color)+B(color))/3.0;
            if(i < 30 && height-j < 30){
                //printf("%3.0f ",255.0);
            }else{
                //printf("%3.0f ", brightness);
            }
            
            if(brightness < 255.0){
                y = j;
                
                if(startX == 0){
                    startX = i;
                }
            }
            
            if(brightness == 255.0 && startX != 0.0){
                endX = i;
                
                NSUInteger median =  ((endX - startX) / 2);
                finalX = startX + median;
                
                brightness = (R(previousColor)+G(previousColor)+B(previousColor))/3.0;
                if(finalX != 0){
                    NSLog(@"Coordinate:(%lu,%lu) = %f",(unsigned long)finalX,(unsigned long)j,brightness);
                }
            }
            
            
            previousColor = *currentPixel;
            currentPixel++;
        }
        printf("\n");
    }
    
    free(pixels);
    
#undef R
#undef G
#undef B
    
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
