//
//  MHPlaceholderAttachmentCell.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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
  NSMutableAttributedString *smallerString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
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
	[smallerString release];
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
