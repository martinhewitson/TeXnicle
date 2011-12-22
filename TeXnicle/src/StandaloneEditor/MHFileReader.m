//
//  MHFileReader.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHFileReader.h"
#import "UKXattrMetadataStore.h"
#import "NSString+FileTypes.h"

@implementation MHFileReader
@synthesize encodings;
@synthesize encodingNames;
@synthesize selectedIndex;

- (id) init
{
  self = [super initWithNibName:@"MHFileReader" bundle:nil];
  if (self) {
    self.encodingNames = [NSArray arrayWithObjects:
                          @"ASCII",
                          @"Unicode (UTF-8)",
                          @"Unicode (UTF-16)",
                          @"Unicode (UTF-16 Little-Endian)",
                          @"Unicode (UTF-16 Big-Endian)",
                          @"Western (ISO Latin 1)",
                          @"Western (ISO Latin 9)",
                          @"Western (Mac OS Roman)",
                          @"Western (Windows Latin 1)",
                          nil];                      
    
    self.encodings = [NSArray arrayWithObjects:
                      [NSNumber numberWithInteger:NSASCIIStringEncoding],
                      [NSNumber numberWithInteger:NSUTF8StringEncoding],
                      [NSNumber numberWithInteger:NSUTF16StringEncoding],
                      [NSNumber numberWithInteger:NSUTF16LittleEndianStringEncoding],
                      [NSNumber numberWithInteger:NSUTF16BigEndianStringEncoding],
                      [NSNumber numberWithInteger:NSISOLatin1StringEncoding],
                      [NSNumber numberWithInteger:NSISOLatin2StringEncoding],
                      [NSNumber numberWithInteger:NSMacOSRomanStringEncoding],
                      [NSNumber numberWithInteger:NSWindowsCP1251StringEncoding],
                      nil];
    self.selectedIndex = [NSNumber numberWithInteger:1];
 }
  return self;
}

- (id) initWithEncodingNamed:(NSString*)encodingName
{
  self = [self init];
  if (self) {
    self.selectedIndex = [NSNumber numberWithInteger:[self indexForEncodingNamed:encodingName]];
  }
  return self;
}

- (id) initWithEncoding:(NSStringEncoding)encoding
{
  self = [self init];
  if (self) {
    self.selectedIndex = [NSNumber numberWithInteger:[self indexForEncoding:encoding]];
  }
  return self;
}

- (void) dealloc
{
  self.encodings = nil;
  self.selectedIndex = nil;
  self.encodingNames = nil;
  [super dealloc];
}

- (NSString*)defaultEncodingName
{
  return [self.encodingNames objectAtIndex:[self.selectedIndex integerValue]];
}

- (NSStringEncoding) defaultEncoding
{
  return [[self.encodings objectAtIndex:[self.selectedIndex integerValue]] integerValue];
}

- (NSInteger)indexForEncoding:(NSStringEncoding)encoding
{
  NSInteger idx = 0;
  for (NSNumber *enc in self.encodings) {
    if ([enc integerValue] == encoding) {
      return idx;
    }
    idx++;
  }
  
  return NSNotFound;
}

                              
- (NSInteger)indexForEncodingNamed:(NSString*)encoding
{
  NSInteger idx = 0;
  for (NSString *enc in self.encodingNames) {
    if ([enc isEqualToString:encoding]) {
      return idx;
    }
    idx++;
  }
        
  return NSNotFound;
}

- (NSStringEncoding)encodingWithName:(NSString*)encoding
{  
  NSInteger idx = [self indexForEncodingNamed:encoding];
  return [[self.encodings objectAtIndex:idx] integerValue];
}

- (NSString*)nameOfEncoding:(NSStringEncoding)encoding
{
  NSInteger idx = 0;
  for (NSNumber *e in self.encodings) {
    if ([e integerValue] == encoding) {
      return [self.encodingNames objectAtIndex:idx];
    }
    idx++;
  }
  return nil;
}


- (BOOL)writeDataToFileAsString:(NSData*)data toURL:(NSURL*)aURL
{
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  NSError *error = nil;
  NSString *content = [[[NSString alloc] initWithData:data
                                            encoding:encoding] autorelease];
  [content writeToURL:aURL atomically:YES encoding:encoding error:&error];
  if (error) {
    [NSApp presentError:error];
    return NO;
  }
  
  return YES;
}


- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL
{
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  NSError *error = nil;
  [aString writeToURL:aURL atomically:YES encoding:encoding error:&error];
  if (error) {
    [NSApp presentError:error];
    return NO;
  }
  
  [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:[aURL path]
                     traverseLink:YES];
  
  return YES;
}

- (NSString*)readStringFromFileAtURL:(NSURL*)aURL
{
  
  if (![[aURL path] pathIsText]) {
    return nil;
  }
  
  NSError *error = nil;
  
  // check the xattr for a string encoding
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  NSString *str = nil;
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  error = nil;
  str = [NSString stringWithContentsOfURL:aURL
                                 encoding:encoding
                                    error:&error];
  
//  NSLog(@"Loaded string %@", str);
  
  if (str == nil) {
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Loading Failed"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Failed to open %@ with encoding %@. Open with another encoding?", [aURL path], [self nameOfEncoding:encoding]];
    [alert setAccessoryView:self.view];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn)       
    {
      encoding = [self defaultEncoding];
      str = [NSString stringWithContentsOfURL:aURL
                                     encoding:encoding
                                        error:&error];
      
    }
  }
  
  if (str != nil) {
    if (![[self nameOfEncoding:encoding] isEqualToString:encodingString]) {
      [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                               forKey:@"com.bobsoft.TeXnicleTextEncoding"
                               atPath:[aURL path]
                         traverseLink:YES];
    }
  }
  
  return str;
}

- (NSStringEncoding)encodingForFileAtPath:(NSString*)aPath
{
  
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:aPath
                                                   traverseLink:YES];
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  return encoding;
}

@end
