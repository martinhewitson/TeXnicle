//
//  TPSupportedFile.h
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSupportedFile : NSObject <NSCoding> {
@private
  NSString *name;
  NSString *ext;
  BOOL isBuiltIn;
  BOOL syntaxHighlight;
}

@property (copy) NSString *name;
@property (copy) NSString *ext;
@property (assign) BOOL isBuiltIn;
@property (assign) BOOL syntaxHighlight;


- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension;
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension;

- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn;
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn;

- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn syntaxHighlight:(BOOL)highlight;
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn syntaxHighlight:(BOOL)highlight;


@end

