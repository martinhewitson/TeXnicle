//
//  TPSectionListSection.m
//  TeXnicle
//
//  Created by Martin Hewitson on 27/01/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPSectionListSection.h"

@implementation TPSectionListSection

- (id) initWithTag:(NSString*)tag isTeX:(BOOL)isTex isMarker:(BOOL)isMark color:(NSColor*)color
{
  self = [self initWithTag:tag isTeX:isTex color:color];
  if (self) {
    self.isMarker = isMark;
  }
  
  return self;
}

- (id) initWithTag:(NSString*)tag isTeX:(BOOL)isTex color:(NSColor*)color
{
  self = [super init];
  if (self) {
    self.color = color;
    self.tag = tag;
    self.isTex = isTex;
    self.isMarker = NO;
    if (isTex) {
      self.regexp = [NSString stringWithFormat:@"\\\\%@\\{.*?(\\n)", tag];
    } else {
      self.regexp = [NSString stringWithFormat:@"%@.*(\\n)", tag];
    }
  }
  return self;
}

@end
