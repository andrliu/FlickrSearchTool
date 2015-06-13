//
//  FlickrManager.h
//  FlickrSearchTool
//
//  Created by Andrew Liu on 6/8/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^urlBlock)(NSString *totalPages, NSArray *arrayOfPhotoURL, NSError *error);
typedef void(^imageblock)(UIImage *image, NSError *error);

@interface FlickrManager : NSObject

+ (void)search:(NSString *)term in:(NSString *)page retrievePhotoURLWithCompletion:(urlBlock)complete;
+ (void)load:(NSString *)urlString retrievePhotoImagesWithCompletion:(imageblock)complete;

@end
