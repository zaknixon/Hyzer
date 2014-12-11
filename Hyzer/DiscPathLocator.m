//
//  DiscPathLocator.m
//  Hyzer
//
//  Created by Zak Nixon on 12/8/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "DiscPathLocator.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

@implementation DiscPathLocator

- (NSArray *) pathContainedInImage:(UIImage *) pathImage{
    NSMutableArray *coordinates = [NSMutableArray array];

    CGImageRef inputCGImage = [pathImage CGImage];
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

    // 2. Iterate and log!
    UInt32 * currentPixel = pixels;
    NSUInteger y =0;
    for (NSUInteger j = 0; j < height; j++) {
        
        NSUInteger startX = 0,endX = 0,finalX = 0;
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
                
                NSUInteger finalY = height - j;
                
                NSString *coordinate = [NSString stringWithFormat:@" %lu   %lu",finalX,finalY ];
                
//                NSLog(@"%lu",finalX);
//                NSLog(@"%lu",finalY);
                [coordinates addObject:coordinate];
                
                startX = 0;
                endX = 0;
            }
            currentPixel++;
        }
    }
    
    free(pixels);

    return coordinates;
}

@end
