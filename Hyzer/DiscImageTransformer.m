//
//  DiscImageTransformer.m
//  Hyzer
//
//  Created by Zak Nixon on 12/8/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import "DiscImageTransformer.h"

@implementation DiscImageTransformer

- (UIImage *) transform:(UIImage *) originalImage{
    UIImage *transformedImage = [UIImage imageWithCGImage:originalImage.CGImage];
    
    //for(Disc *d in discs){
        //NSString *stringURL = [NSString stringWithFormat:@"http://www.inboundsdiscgolf.com/content/WebCharts/%@.png",d.imageId];
        //NSURL  *url = [NSURL URLWithString:stringURL];
        //NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        //if(urlData){
            
            //UIImage *image = [UIImage imageWithData:urlData];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSString *fileName = [NSString stringWithFormat:@"%@-%@.png",d.manufacturer,d.name];
//            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
//            [urlData writeToFile:appFile atomically:YES];
    
            CIFilter *exposure = [CIFilter filterWithName:@"CIExposureAdjust"];
            [exposure setDefaults];
            [exposure setValue:[[CIImage alloc] initWithImage:transformedImage] forKey:kCIInputImageKey];
            [exposure setValue:@0.9 forKey:@"inputEV"];
            CIImage *result = [exposure valueForKey: kCIOutputImageKey];

            for(int i = 0; i < 45; i++){
                CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
                [lighten setDefaults];
                [lighten setValue:result forKey:kCIInputImageKey];
                [lighten setValue:@1.3 forKey:@"inputContrast"];
                result = [lighten valueForKey: kCIOutputImageKey];
                
            }
    
//            for(int i = 0; i < 15; i++){
//                CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
//                [sepia setValue:[[CIImage alloc] initWithImage:transformedImage] forKey:kCIInputImageKey];
//                [sepia setValue:@(0.75) forKey:@"inputIntensity"];
//                result = [sepia valueForKey:kCIOutputImageKey];
//            }
    
            transformedImage = [UIImage imageWithCIImage:result];
            
            UIGraphicsBeginImageContext(transformedImage.size);
            [transformedImage drawInRect:CGRectMake(0, 0, transformedImage.size.width, transformedImage.size.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGRect cropRect = CGRectMake(27,20,newImage.size.width-49,newImage.size.height-45);
            CGImageRef cgImage = [newImage CGImage];
            CGImageRef imageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
            // or use the UIImage wherever you like
            newImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
    
            transformedImage = newImage;
    
//            NSData *imageData = UIImagePNGRepresentation(newImage);
//            fileName = [NSString stringWithFormat:@"%@-%@44.png",d.manufacturer,d.name];
//            appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
//            [imageData writeToFile:appFile atomically:YES];
    
            //[self logPixelsOfImage:newImage];
        //}
    //}

    return transformedImage;
}


@end
