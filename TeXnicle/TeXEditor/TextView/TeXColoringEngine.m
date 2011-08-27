//
//  TeXColouringEngine.m
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TeXColoringEngine.h"
#import "externs.h"
#import "TeXTextView.h"
#import "NSArray+Color.h"

#define kHighlightInterval 0.1

@implementation TeXColoringEngine

@synthesize lastHighlight;

@synthesize textView;

@synthesize textColor;
@synthesize textFont;

@synthesize commentColor;
@synthesize colorComments;

@synthesize specialCharsColor;
@synthesize colorSpecialChars;

@synthesize commandColor;
@synthesize colorCommand;

@synthesize argumentsColor;
@synthesize colorArguments;


+ (TeXColoringEngine*)coloringEngineWithTextView:(NSTextView*)aTextView
{
  return [[[TeXColoringEngine alloc] initWithTextView:aTextView] autorelease];
}
           
- (id) initWithTextView:(NSTextView*)aTextView
{
  self = [super init];
  if (self) {
    self.textView = aTextView;
    newLineCharacterSet = [[NSCharacterSet newlineCharacterSet] retain];
    whitespaceCharacterSet = [[NSCharacterSet whitespaceCharacterSet] retain];	
    specialChars = [[NSCharacterSet characterSetWithCharactersInString:@"${}[]()\"'"] retain];
    
    keys = [[NSArray arrayWithObjects:TEDocumentFont, TESyntaxTextColor,
             TESyntaxCommentsColor, TESyntaxColorComments, 
             TESyntaxSpecialCharsColor, TESyntaxColorSpecialChars, 
             TESyntaxCommandColor, TESyntaxColorCommand, 
             TESyntaxArgumentsColor, TESyntaxColorArguments,
             nil] retain];

    [self readColorsAndFontsFromPreferences];
    [self observePreferences];
    
  }
  return self;
}

- (void) awakeFromNib
{
}

- (void)dealloc
{
  [self stopObserving];
  
  self.lastHighlight = nil;
  self.textColor = nil;
  self.textFont = nil;
  self.commentColor = nil;
  self.specialCharsColor = nil;
  self.commandColor = nil;
  self.argumentsColor = nil;
  
  [keys release];
  [specialChars release];
	[newLineCharacterSet release];
	[whitespaceCharacterSet release];
  [super dealloc];
}

#pragma mark -
#pragma mark KVO 

- (void) stopObserving
{
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  for (NSString *str in keys) {
    [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", str]];
  }
}

- (void) observePreferences
{  
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  
  for (NSString *str in keys) {
    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", str]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];		
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  for (NSString *str in keys) {
    if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", str]]) {
      [self readColorsAndFontsFromPreferences];
      if ([textView respondsToSelector:@selector(colorVisibleText)]) {
        [textView performSelector:@selector(colorVisibleText)];
      }
      self.lastHighlight = nil;
      if ([textView respondsToSelector:@selector(colorWholeDocument)]) {
        [textView performSelector:@selector(colorWholeDocument) withObject:nil afterDelay:0];
      }
    }    
  }
}


- (void) readColorsAndFontsFromPreferences
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  // basic text
  self.textFont = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];
  self.textColor = [[defaults valueForKey:TESyntaxTextColor] colorValue];
  
  // comments
  self.commentColor = [[defaults valueForKey:TESyntaxCommentsColor] colorValue];
  self.colorComments = [[defaults valueForKey:TESyntaxColorComments] boolValue];

  // math
  self.specialCharsColor = [[defaults valueForKey:TESyntaxSpecialCharsColor] colorValue];
  self.colorSpecialChars = [[defaults valueForKey:TESyntaxColorSpecialChars] boolValue];
  
  // command
  self.commandColor = [[defaults valueForKey:TESyntaxCommandColor] colorValue];
  self.colorCommand = [[defaults valueForKey:TESyntaxColorCommand] boolValue];
  
  // arguments
  self.argumentsColor = [[defaults valueForKey:TESyntaxArgumentsColor] colorValue];
  self.colorArguments = [[defaults valueForKey:TESyntaxColorArguments] boolValue];
  
}


- (void) colorTextView:(NSTextView*)aTextView textStorage:(NSTextStorage*)textStorage layoutManager:(NSLayoutManager*)layoutManager inRange:(NSRange)aRange
{
  
  if (self.lastHighlight) {
    if ([[NSDate date] timeIntervalSinceDate:self.lastHighlight] < kHighlightInterval) {
      return;
    }
  }
  
//  NSLog(@"Coloring %@", NSStringFromRange(aRange));
  
  NSString *text = [[textStorage string] substringWithRange:aRange];
  NSInteger strLen = [text length];
  if (strLen == 0) {
    return;
  }
  
  // make sure the glyphs are present otherwise colouring gives errors
  [layoutManager ensureGlyphsForCharacterRange:aRange];
  
  
  // apply default font and color, if necessary
//  NSDictionary *currentAtts = [textStorage attributesAtIndex:aRange.location effectiveRange:NULL];
//  NSColor *currentTextColor = [currentAtts valueForKey:NSForegroundColorAttributeName];
//  NSFont *currentTextFont = [currentAtts valueForKey:NSFontAttributeName];
//  if (![currentTextColor isEqualTo:self.textColor] || ![currentTextFont isEqualTo:self.textFont]) {
  
    // Note to self: replace this by setting typing attributes and by setting attributes when 
    // textstorage is created.
  
//    [textStorage beginEditing];  
//    [textStorage addAttribute:NSForegroundColorAttributeName value:self.textColor range:aRange];
//    [textStorage addAttribute:NSFontAttributeName value:self.textFont range:aRange];		  
//    [textStorage endEditing];
//  }
  
  // remove existing temporary attributes
	[layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:aRange];
    
  // scan each character in the string
  NSUInteger idx;
  unichar cc;
  unichar nextChar;
  NSRange lineRange;
  NSRange colorRange;
  NSInteger start;
  for (idx = 0; idx < strLen; idx++) {
    
    cc  = [text characterAtIndex:idx];
//    NSLog(@"Checking %c", cc);
    // color comments
    if (cc == '%' && self.colorComments) {
      // comment rest of the line
      lineRange = [text lineRangeForRange:NSMakeRange(idx, 0)];
      colorRange = NSMakeRange(aRange.location+idx, NSMaxRange(lineRange)-idx);
      unichar c = 0;
			if (idx>0) {
				c = [text characterAtIndex:idx-1];
			}
			if (idx==0 || c != '\\') {

//          [newLineCharacterSet characterIsMember:c] ||
//          [whitespaceCharacterSet characterIsMember:c]) {
        [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.commentColor forCharacterRange:colorRange];
        idx = NSMaxRange(lineRange)-1;
			}
    } else if ((cc == '{') && self.colorArguments) {      
      start = idx;
      // look for the closing bracket
      idx++;
      NSInteger argCount = 1;
      while(idx < strLen) {
        nextChar = [text characterAtIndex:idx];
        if (nextChar == '{') {
          argCount++;
        }
        if (nextChar == '}') {
          argCount--;
        }
        if (argCount == 0) {
          NSRange argRange = NSMakeRange(aRange.location+start,idx-start+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.argumentsColor forCharacterRange:argRange];
          break;
        }
        idx++;
      }
    } else if ((cc == '[') && self.colorArguments) {      
      start = idx;
      // look for the closing bracket
      idx++;
      NSInteger argCount = 1;
      while(idx < strLen) {
        nextChar = [text characterAtIndex:idx];
        if (nextChar == '[') {
          argCount++;
        }
        if (nextChar == ']') {
          argCount--;
        }
        if (argCount == 0) {
          NSRange argRange = NSMakeRange(aRange.location+start,idx-start+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.argumentsColor forCharacterRange:argRange];
          break;
        }
        idx++;
      }
    } else if ([specialChars characterIsMember:cc] && self.colorSpecialChars) { // (cc == '$' || cc == '{'&& self.colorMath) {
      
      colorRange = NSMakeRange(aRange.location+idx, 1);
      [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.specialCharsColor forCharacterRange:colorRange];
    } else if ((cc == '\\' || cc == '@') && self.colorCommand) {      
      // if we find \ we start a command unless we have \, or whitespace
      if (idx < strLen-1) {
        nextChar = [text characterAtIndex:idx+1];
        if (nextChar == ',' || [whitespaceCharacterSet characterIsMember:nextChar]) {
          // do nothing
        } else {
          // highlight word
          NSRange wordRange = [textStorage doubleClickAtIndex:aRange.location+idx+1];
          colorRange = NSMakeRange(wordRange.location-1, wordRange.length+1);
          [layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.commandColor forCharacterRange:colorRange];
          idx += colorRange.length-1;
        }
      }            
//    } else if ((cc == '[') && self.colorArguments) {      
    } else {
      // do nothing
    }    
  } 
  self.lastHighlight = [NSDate date];
}



@end
