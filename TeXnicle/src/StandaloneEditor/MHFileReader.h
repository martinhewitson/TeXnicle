//
//  MHFileReader.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MHFileReader : NSViewController

@property (retain) NSArray *encodings;
@property (retain) NSArray *encodingNames;
@property (retain) NSNumber *selectedIndex;

- (id) initWithEncoding:(NSStringEncoding)encoding;
- (id) initWithEncodingNamed:(NSString*)encodingName;
- (NSString*)readStringFromFileAtURL:(NSURL*)aURL;
- (NSStringEncoding)encodingWithName:(NSString*)encoding;
- (NSInteger)indexForEncodingNamed:(NSString*)encoding;
- (NSString*)defaultEncodingName;
- (NSStringEncoding) defaultEncoding;
- (NSString*)nameOfEncoding:(NSStringEncoding)encoding;
- (NSInteger)indexForEncoding:(NSStringEncoding)encoding;
- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL;
- (BOOL)writeDataToFileAsString:(NSData*)data toURL:(NSURL*)aURL;
- (NSStringEncoding)encodingForFileAtPath:(NSString*)aPath;

@end
