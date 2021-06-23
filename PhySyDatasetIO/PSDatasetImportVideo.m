//
//  PSDatasetImportVideo.c
//  PhySyDatasetIO
//
//  Created by Philip J. Grandinetti on 2/16/12.
//  Copyright (c) 2012 PhySy Ltd. All rights reserved.
//

#import <LibPhySyObjC/PhySyDatasetIO.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

//bool PSDatasetImportVideoIsValidURL(CFURLRef url)
//{
//    bool result = false;
//    CFStringRef extension = CFURLCopyPathExtension(url);
//    if(extension) {
//        if(CFStringCompare(extension, CFSTR("mov"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) result = true;
//        if(CFStringCompare(extension, CFSTR("avi"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) result = true;
//        CFRelease(extension);
//    }
//    return result;
//}
//
//CFIndex PSDatasetImportVideoNumberOfDimensionsForURL(CFURLRef url)
//{
//    return 3;
//}
//
PSDatasetRef PSDatasetCreateWithVideoURL(CFURLRef url, CFErrorRef *error)
{
    if(error) if(*error) return NULL;
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:(NSURL *) url options:options];
    NSLog(@"%@",asset);
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    CMTime actualTime;
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:(NSError **)error];
    [imageGenerator release];
    [asset release];
    
    if (halfWayImage) {
        
        NSString *actualTimeString = (NSString *)CMTimeCopyDescription(NULL, actualTime);
        NSString *requestedTimeString = (NSString *)CMTimeCopyDescription(NULL, midpoint);
        NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);
        
        // Do something interesting with the image.
        PSDatasetRef dataset = PSDatasetImportImageCreateSignalWithCGImage(halfWayImage, error);
        [actualTimeString release];
        [requestedTimeString release];

        CGImageRelease(halfWayImage);
        return dataset;
    }
        
    return NULL;
}



