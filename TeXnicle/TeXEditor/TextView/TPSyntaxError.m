//
//  TPSyntaxError.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSyntaxError.h"
#import "RegexKitLite.h"

@implementation TPSyntaxError

@synthesize line;
@synthesize message;

+ (id) errorWithMessageLine:(NSString*)aLine
{
  return [[[TPSyntaxError alloc] initWithMessageLine:aLine] autorelease];
}

- (id) initWithMessageLine:(NSString*)aLine
{
  self = [super init];
  if (self) {
    
    self.line = [NSNumber numberWithInteger:NSNotFound];
    self.message = @"";
    
    [self parseMessageLine:aLine];
    
  }
  return self;
}

- (void) parseMessageLine:(NSString*)aLine
{
  NSArray *comps = [aLine captureComponentsMatchedByRegex:@"line ([0-9]*):(.*)"];
  if ([comps count] >= 2) {
    self.line = [NSNumber numberWithInteger:[[comps objectAtIndex:1] integerValue]];
  }
  if ([comps count] >= 3) {
    self.message = [comps objectAtIndex:2];
  }
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"line %@: %@", self.line, self.message];
}

- (NSAttributedString*)attributedString
{
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
  
  // line number
  NSMutableAttributedString *lineNumber = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"line %@: ", self.line]] autorelease];
  [lineNumber addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [lineNumber length])];
  [str appendAttributedString:lineNumber];

  // message 
  NSMutableAttributedString *messageString = [[[NSMutableAttributedString alloc] initWithString:self.message] autorelease];
  [messageString addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, [messageString length])];
  [str appendAttributedString:messageString];
  
  return str;
}

@end
