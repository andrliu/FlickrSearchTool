//
//  FlickrManager.m
//  FlickrSearchTool
//
//  Created by Andrew Liu on 6/8/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

#import "FlickrManager.h"

#define flickrKey @"763b5ed98a431551082c258cba223c50"
#define perPage @"10"

@implementation FlickrManager

+ (void)search:(NSString *)term in:(NSString *)page retrievePhotoURLWithCompletion:(urlBlock)complete {
    NSString *urlString = [NSString stringWithFormat: @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=%@&page=%@&format=json&nojsoncallback=1", flickrKey, term, perPage, page];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError && data) {
            NSError *error = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if(!error && jsonDictionary)
            {
                NSMutableArray *arrayOfPhotoURL = [NSMutableArray array];
                NSDictionary *photosDictionary = jsonDictionary[@"photos"];
                NSString *totalPages = photosDictionary[@"pages"];
                NSArray *photoArray = photosDictionary[@"photo"];
                for (NSDictionary *photoDictionary in photoArray) {
                    NSString *farmID = photoDictionary[@"farm"];
                    NSString *serverID = photoDictionary[@"server"];
                    NSString *userID = photoDictionary[@"id"];
                    NSString *secretID = photoDictionary[@"secret"];
                    NSString *photoURLString = [NSString stringWithFormat: @"https://farm%@.staticflickr.com/%@/%@_%@.jpg", farmID, serverID, userID, secretID];
                    [arrayOfPhotoURL addObject:photoURLString];
                }
                complete(totalPages, arrayOfPhotoURL, nil);
            }
            else
            {
                complete(nil, nil,error);
            }
        }
        else {
            complete(nil, nil,connectionError);
        }
    }];
}

+ (void)load:(NSString *)urlString retrievePhotoImagesWithCompletion:(imageblock)complete {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError && data) {
            UIImage *image = [[UIImage alloc]initWithData:data];
            complete (image, nil);
        }
        else {
            complete(nil,connectionError);
        }
    }];
}


@end
