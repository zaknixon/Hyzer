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

@interface AppDelegate ()

@end

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    DiscInformationRetriever *retriever = [[DiscInformationRetriever alloc] init];
    [retriever retrieveDiscsAndPerformBlock:^(NSArray *discs) {
        [self processDiscs:discs];
    }];
    
    return YES;
}

- (void) processDiscs:(NSArray *) discs{
    
    for(Disc *d in discs){
        NSString *stringURL = [NSString stringWithFormat:@"http://www.inboundsdiscgolf.com/content/WebCharts/%@.png",d.imageId];
        NSURL  *url = [NSURL URLWithString:stringURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        if(urlData){
            
            UIImage *image = [UIImage imageWithData:urlData];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileName = [NSString stringWithFormat:@"%@-%@.png",d.manufacturer,d.name];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
            [urlData writeToFile:appFile atomically:YES];
            
            CIFilter *exposure = [CIFilter filterWithName:@"CIExposureAdjust"];
            [exposure setDefaults];
            [exposure setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
            [exposure setValue:@0.9 forKey:@"inputEV"];
            CIImage *result = [exposure valueForKey: kCIOutputImageKey];
     
            for(int i = 0; i < 45; i++){
            CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
            [lighten setDefaults];
            [lighten setValue:result forKey:kCIInputImageKey];
            [lighten setValue:@1.3 forKey:@"inputContrast"];
            result = [lighten valueForKey: kCIOutputImageKey];
            
            }

            for(int i = 0; i < 15; i++){
                CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
                [sepia setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
                [sepia setValue:@(0.75) forKey:@"inputIntensity"];
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
    UInt32 * currentPixel = pixels;
    NSUInteger y =0;
    for (NSUInteger j = 0; j < height; j++) {
        
        NSUInteger startX = 0,endX = 0,finalX = 0;
        UInt32 previousColor;
        y = 0;
        for (NSUInteger i = 0; i < width; i++) {
            UInt32 color = *currentPixel;
            
            float brightness = (R(color)+G(color)+B(color))/3.0;
            if(i < 30 && height-j < 30){
                continue;
            }
            
            if((brightness < 255.0 && brightness != 0)){
                y = j;
                
                if(startX == 0){
                    startX = i;
                }
                
            }
            
            if(brightness == 255.0 && startX != 0){
                endX = i;
                
                NSUInteger median =  ((endX - startX) / 2);
                finalX = startX + median;
                NSLog(@" %lu   %lu",finalX,j);

                startX = 0;
                endX = 0;
            }
            currentPixel++;
        }
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
