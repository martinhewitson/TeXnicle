//
//  MHPlaceholderAttachmentCell.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "MHPlaceholderAttachmentCell.h"
#import "externs.h"

@implementation MHPlaceholderAttachmentCell

- (id) initTextCell:(NSString *)aString
{
	//NSLog(@"Init text cell");
	self = [super initTextCell:aString];
	if (self) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSFont *f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];									
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:f forKey:NSFontAttributeName];
    [dict setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString
																															attributes:dict];
		[self setAttributedStringValue:str];
		[self setEditable:YES];
		[str release];
		
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{
  NSColor *cellColor = [NSColor colorWithDeviceRed:150.0/255.0 green:180.0/255.0 blue:240.0/255.0 alpha:0.5];
  [cellColor set];
  //	NSRectFill(cellFrame);
	NSBezierPath *bp = [NSBezierPath bezierPath];
	NSRect irect = NSInsetRect(cellFrame, 1, 1);
	[bp appendBezierPathWithRoundedRect:NSMakeRect(irect.origin.x, 
																								 irect.origin.y, 
																								 irect.size.width, 
																								 irect.size.height) 
															xRadius:0.3*irect.size.height
															yRadius:0.5*irect.size.height];
	
	[bp fill];
  
  [[NSColor colorWithDeviceRed:120.0/255.0 green:150.0/255.0 blue:255.0/255.0 alpha:0.8] set];
  [bp setLineWidth:1.0];
  [bp stroke];
  
  NSAttributedString *string = [self attributedStringValue];
	NSSize strSize = [string size];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSFont *f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];									
  NSMutableAttributedString *smallerString = [[[NSMutableAttributedString alloc] initWithAttributedString:string] autorelease];
  [smallerString addAttribute:NSFontAttributeName 
                        value:[NSFont fontWithName:[f fontName] size:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]   
                        range:NSMakeRange(0, [string length])];
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
  [ps setAlignment:NSCenterTextAlignment];
  [smallerString addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [smallerString length])];
  [ps release];
	NSSize smallSize = [smallerString size];
  NSRect r = NSMakeRect(irect.origin.x+(irect.size.width-strSize.width)/2.0, 
												irect.origin.y+irect.size.height/2.0-smallSize.height/2.0, 
												strSize.width, strSize.height);
	[smallerString drawInRect:r];
	
}

- (NSSize) cellSize
{
	NSAttributedString *str = [self attributedStringValue];
	NSSize strSize = [str size];
	return NSMakeSize(1.1*strSize.width, strSize.height);
}

- (NSPoint)cellBaselineOffset
{
  return NSMakePoint(0, -5);
}

@end
