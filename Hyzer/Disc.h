//
//  Disc.h
//  Hyzer
//
//  Created by Zak Nixon on 12/1/14.
//  Copyright (c) 2014 Zak Nixon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Disc : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *manufacturer;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *distance;
@property (nonatomic,strong) NSString *hst;
@property (nonatomic,strong) NSString *lsf;
@property (nonatomic,strong) NSString *net;
@property (nonatomic,strong) NSString *imageId;
@property (nonatomic,strong) UIImage  *flightPathImage;
@end
