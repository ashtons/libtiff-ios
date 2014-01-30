//
//  TiffUtils.m
//  TiffExample
//
//  Created by Sean Ashton on 31/01/2014.
//  Copyright (c) 2014 Schimera Pty Ltd. All rights reserved.
//

#import "TiffUtils.h"
#include "tiffio.h"




@implementation TiffUtils


+(NSInteger) numberOfFramesInFile:(NSString *)path {
    int frames = 0;
    TIFF *tmpImage = TIFFOpen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (tmpImage != NULL) {
        frames = TIFFNumberOfDirectories(tmpImage);
        TIFFClose(tmpImage);
        tmpImage = NULL;
    }
    return frames;
}
@end
