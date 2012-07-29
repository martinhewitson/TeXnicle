//
//  MHFileReader.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MHFileReader.h"
#import "UKXattrMetadataStore.h"
#import "NSString+FileTypes.h"
#import "externs.h"

@implementation MHFileReader
@synthesize encodings;
@synthesize encodingNames;
@synthesize selectedIndex;

+ (NSStringEncoding)defaultEncoding
{
  NSString *defaultEncodingName = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
  MHFileReader *fr = [[MHFileReader alloc] init];
  return [fr encodingWithName:defaultEncodingName];
}

+ (NSString*)defaultEncodingName
{
  NSString *defaultEncodingName = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
  return defaultEncodingName;
}


- (id) init
{
  self = [super initWithNibName:@"MHFileReader" bundle:nil];
  if (self) {
    self.encodingNames = @[@"ASCII",
                          @"Unicode (UTF-8)",
                          @"Unicode (UTF-16)",
                          @"Unicode (UTF-16 Little-Endian)",
                          @"Unicode (UTF-16 Big-Endian)",
                          @"Western (ISO Latin 1)",
                          @"Western (ISO Latin 9)",
                          @"Western (Mac OS Roman)",
                          @"Western (Windows Latin 1)"];                      
    
    self.encodings = @[@(NSASCIIStringEncoding),
                      @(NSUTF8StringEncoding),
                      @(NSUTF16StringEncoding),
                      @(NSUTF16LittleEndianStringEncoding),
                      @(NSUTF16BigEndianStringEncoding),
                      @(NSISOLatin1StringEncoding),
                      @(NSISOLatin2StringEncoding),
                      @(NSMacOSRomanStringEncoding),
                      @(NSWindowsCP1251StringEncoding)];
    self.selectedIndex = @1;
 }
  return self;
}

- (id) initWithEncodingNamed:(NSString*)encodingName
{
  self = [self init];
  if (self) {
    self.selectedIndex = @([self indexForEncodingNamed:encodingName]);
  }
  return self;
}

- (id) initWithEncoding:(NSStringEncoding)encoding
{
  self = [self init];
  if (self) {
    self.selectedIndex = @([self indexForEncoding:encoding]);
  }
  return self;
}


- (NSString*)defaultEncodingName
{
  return (self.encodingNames)[[self.selectedIndex integerValue]];
}

- (NSStringEncoding) defaultEncoding
{
  NSString *defaultEncodingName = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
//  NSLog(@"Getting default encoding...%@", defaultEncodingName);
  return [self encodingWithName:defaultEncodingName];
  //  return [[self.encodings objectAtIndex:[self.selectedIndex integerValue]] integerValue];
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
  return [(self.encodings)[idx] integerValue];
}

- (NSString*)nameOfEncoding:(NSStringEncoding)encoding
{
  NSInteger idx = 0;
  for (NSNumber *e in self.encodings) {
    if ([e integerValue] == encoding) {
      return (self.encodingNames)[idx];
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
//  NSLog(@"Write to file at URL %@", aURL);
//  NSLog(@"Encoding string %@", encodingString);
  
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  NSError *error = nil;
  NSString *content = [[NSString alloc] initWithData:data
                                            encoding:encoding];
  
  // TODO: Check that the URL we want to write to is a file and not a directory
  // Don't know a better way that just checking that the path has an extension?
  
//  NSLog(@"Writing with encoding %@", [self nameOfEncoding:encoding]);
  
  BOOL result = [content writeToURL:aURL atomically:YES encoding:encoding error:&error];
  
  if (result == NO) {
    [NSApp presentError:error];
    return NO;
  }
  
//  NSLog(@"Data written to file.");
  
  return YES;
}


- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL withEncoding:(NSStringEncoding)encoding
{
//  NSLog(@"Write string to %@ with encoding %@", aURL, [self nameOfEncoding:encoding]);
  
  NSError *error = nil;
  BOOL success = [aString writeToURL:aURL atomically:YES encoding:encoding error:&error];
  if (success == NO) {
    [NSApp presentError:error];
    return NO;
  }
  
  [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:[aURL path]
                     traverseLink:YES];
  
  return YES;
}

- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL
{
//  NSLog(@"Write string to URL %@", aURL);
  
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  return [self writeString:aString toURL:aURL withEncoding:encoding];
}

- (NSString*)readStringFromFileAtURL:(NSURL*)aURL
{
//  NSLog(@"Reading string from file %@", aURL);
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
    
    str = [NSString stringWithContentsOfURL:aURL usedEncoding:&encoding error:&error];
    //    NSLog(@"Loaded string %@", str);
    // if we didn't get a string, then try the default encoding
    if (str == nil || [str isEqualToString:@""]) {
      //      NSLog(@"   failed to guess.");
      encoding = [self defaultEncoding];
      //      NSLog(@" using default encoding %@", [self nameOfEncoding:encoding]);
    }
    
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  //  NSLog(@"Reading string with encoding %@", encodingString);
  // if we didn't get the string, try with the default encoding
  if (str == nil) {
    error = nil;
    str = [NSString stringWithContentsOfURL:aURL
                                   encoding:encoding
                                      error:&error];
    
  }  
  
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
      // get the encoding the user selected
      encoding = [(self.encodings)[[self.selectedIndex integerValue]] integerValue];
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
  
  // set the encoding we used in the end
  self.selectedIndex = @([self indexForEncoding:encoding]);
  
  return str;
}

- (NSString*)silentlyReadStringFromFileAtURL:(NSURL*)aURL
{
  //  NSLog(@"Reading string from file %@", aURL);
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
    
    str = [NSString stringWithContentsOfURL:aURL usedEncoding:&encoding error:&error];
    //    NSLog(@"Loaded string %@", str);
    // if we didn't get a string, then try the default encoding
    if (str == nil || [str isEqualToString:@""]) {
      //      NSLog(@"   failed to guess.");
      encoding = [self defaultEncoding];
      //      NSLog(@" using default encoding %@", [self nameOfEncoding:encoding]);
    }
    
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  //  NSLog(@"Reading string with encoding %@", encodingString);
  // if we didn't get the string, try with the default encoding
  if (str == nil) {
    error = nil;
    str = [NSString stringWithContentsOfURL:aURL
                                   encoding:encoding
                                      error:&error];
    
  }  
  
  //  NSLog(@"Loaded string %@", str);  
  if (str != nil) {
    if (![[self nameOfEncoding:encoding] isEqualToString:encodingString]) {
      [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                               forKey:@"com.bobsoft.TeXnicleTextEncoding"
                               atPath:[aURL path]
                         traverseLink:YES];
    }
  }
  
  // set the encoding we used in the end
  self.selectedIndex = @([self indexForEncoding:encoding]);
  
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

- (NSStringEncoding)encodingUsed
{
  return [(self.encodings)[[self.selectedIndex integerValue]] integerValue];
}

@end
