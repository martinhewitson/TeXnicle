//
//  TPSupportedFile.m
//  TeXnicle
//
//  Created by Martin Hewitson on 06/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSupportedFile.h"

@implementation TPSupportedFile

@synthesize name;
@synthesize ext;
@synthesize isBuiltIn;
@synthesize syntaxHighlight;

// Initialise with a name and extension.
// Built-in defaults to NO.
// Syntax highlighting defaults to NO.
- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension
{
  self = [super init];
  if (self) {
    self.name = aName;
    self.ext = anExtension;
    self.isBuiltIn = NO;
    self.syntaxHighlight = NO;
  }
  return self;
}

// Convenience constructor
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension
{
  return [[[TPSupportedFile alloc] initWithName:aName extension:anExtension] autorelease];
}

// Init with name and extension, and flag as built-in or not
- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn
{
  self = [self initWithName:aName extension:anExtension];
  if (self) {
    self.isBuiltIn = builtIn;
  }
  return self;
}

// Convenience constructor
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn
{
  return [[[TPSupportedFile alloc] initWithName:aName extension:anExtension isBuiltIn:builtIn] autorelease];
}

// Init with name, extension, built-in and syntax highlight flags
- (id) initWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn syntaxHighlight:(BOOL)highlight
{
  self = [self initWithName:aName extension:anExtension isBuiltIn:builtIn];
  if (self) {
    self.syntaxHighlight = highlight;
  }
  return self;
}

// Convenience constructor
+ (TPSupportedFile*)supportedFileWithName:(NSString*)aName extension:(NSString*)anExtension isBuiltIn:(BOOL)builtIn syntaxHighlight:(BOOL)highlight
{
  return [[[TPSupportedFile alloc] initWithName:aName extension:anExtension isBuiltIn:builtIn syntaxHighlight:highlight] autorelease];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"%@: '%@', builtIn=%d, syntaxHighlight=%d", self.ext, self.name, self.isBuiltIn, self.syntaxHighlight];
}

#pragma mark -
#pragma mark Support for NSCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.ext  = [aDecoder decodeObjectForKey:@"ext"];
    self.isBuiltIn = [aDecoder decodeBoolForKey:@"isBuiltIn"];
    self.syntaxHighlight = [aDecoder decodeBoolForKey:@"syntaxHighlight"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:self.name forKey:@"name"];
  [aCoder encodeObject:self.ext forKey:@"ext"];
  [aCoder encodeBool:self.isBuiltIn forKey:@"isBuiltIn"];
  [aCoder encodeBool:self.syntaxHighlight forKey:@"syntaxHighlight"];
}


@end
