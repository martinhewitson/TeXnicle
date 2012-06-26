//
//  NSWorkspaceExtended.m
//  LaTeXiT
//
//  Created by Pierre Chatelier on 19/07/05.
//  Copyright 2005, 2006, 2007, 2008, 2009 Pierre Chatelier. All rights reserved.
//

//this file is an extension of the NSWorkspace class

#import "NSWorkspaceExtended.h"

@implementation NSWorkspace (Extended)

-(NSString*) applicationName
{
  NSString* result = nil;
  CFDictionaryRef bundleInfoDict = CFBundleGetInfoDictionary(CFBundleGetMainBundle());
  result = (NSString*) CFDictionaryGetValue( bundleInfoDict, CFSTR("AMName"));
  if (!result)
    result = (NSString*) CFDictionaryGetValue( bundleInfoDict, CFSTR("CFBundleExecutable"));
  return result;
}
//end applicationName

-(NSString*) applicationVersion
{
  NSString* result = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  return result;
}
//end applicationVersion

-(NSString*) temporaryDirectory
{
  NSString* thisVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  if (!thisVersion)
    thisVersion = @"";
  NSArray* components = [thisVersion componentsSeparatedByString:@" "];
  if (components && [components count])
    thisVersion = [components objectAtIndex:0];

  NSString* temporaryPath =
    [NSTemporaryDirectory() stringByAppendingPathComponent:
      [NSString stringWithFormat:@"%@-%@", [self applicationName], thisVersion]];
  NSFileManager* fileManager = [NSFileManager defaultManager];
  BOOL isDirectory = NO;
  BOOL exists = [fileManager fileExistsAtPath:temporaryPath isDirectory:&isDirectory];
  if (exists && !isDirectory)
  {
    NSError *error = nil;
    BOOL success = [fileManager removeItemAtPath:temporaryPath error:&error];
    if (success == NO) {
      [NSApp presentError:error];
    }
    exists = NO;
  }
  if (!exists) {
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtPath:temporaryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (success == NO) {
      [NSApp presentError:error];
    }
  }
  return temporaryPath;
}
//end temporaryDirectory

-(NSString*) getBestStandardPast:(NSSearchPathDirectory)searchPathDirectory domain:(NSSearchPathDomainMask)domain defaultValue:(NSString*)defaultValue
{
  NSString* result = nil;
  NSArray*  candidates = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domain, YES);
  NSFileManager* fileManager = [NSFileManager defaultManager];
  BOOL isDirectory = YES;
  NSEnumerator* enumerator = [candidates objectEnumerator];
  NSString*     candidate  = nil;
  while(!result && ((candidate = [enumerator nextObject])))
  {
    if ([fileManager fileExistsAtPath:candidate isDirectory:&isDirectory] && isDirectory)
      result = candidate;
  }//else for each candidate
  
  if (!result)
    result = defaultValue;
  
  return result;
}
//end getBestStandardPast:domain:defaultValue:

@end

@implementation NSWorkspace (Bridge10_5)

-(BOOL) filenameExtension:(NSString*)filenameExtension isValidForType:(NSString *)typeName
{
  BOOL result = YES;
  return result;
}
//end filenameExtension:isValidForType:

@end
