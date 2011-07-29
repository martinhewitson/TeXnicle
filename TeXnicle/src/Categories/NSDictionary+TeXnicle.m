//
//  NSDictionary+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 29/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "NSDictionary+TeXnicle.h"
#import "externs.h"
#import "NSArray+Color.h"

@implementation NSDictionary (TeXnicle)

+ (NSDictionary*)currentTypingAttributes
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
  NSColor *color = [[defaults valueForKey:TESyntaxTextColor] colorValue];
  return [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
}

@end
