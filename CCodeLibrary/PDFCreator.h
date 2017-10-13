//
//  PDFCreator.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/13/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PDFCreate_OK    0
#define PDFCreate_FAIL  1

@interface PDFPageImage : NSObject
@property NSString * imageFile;
@property CGRect imageLocation;
@end

@interface PDFPageTextBlock : NSObject
@property NSString * text;
@property NSFont * font;
@property CGRect textLocation;
@end

@interface PDFPage : NSObject
@property int pageWidth, pageHeight;
@property NSArray * PDFPageImages;
@property NSArray * PDFPageTextBlocks;
@end


@interface PDFCreator : NSObject
+ (int) writePDFtoFile:(NSString *)filePath
         fromPageArray:(NSArray*) pageArray;

@end

