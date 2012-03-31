//
//  TPFoldedCell.m
//  TeXnicle
//
//  Created by Martin Hewitson on 25/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPFoldedAttachmentCell.h"
#import "externs.h"

@implementation TPFoldedAttachmentCell

- (id) initTextCell:(NSString *)aString
{
	//NSLog(@"Init text cell");
	self = [super initTextCell:aString];
	if (self) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSFont *f = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];									
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:f forKey:NSFontAttributeName];
		NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString
																															attributes:dict];
		[self setAttributedStringValue:str];
		
		[str release];
		
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{
	
	[[NSColor colorWithDeviceRed:246.0/255.0 green:246.0/255.0 blue:172.0/255.0 alpha:1.0] set];
//	NSRectFill(cellFrame);
	NSBezierPath *bp = [[NSBezierPath alloc] init];
	NSRect irect = NSInsetRect(cellFrame, 3, 0);
	[bp appendBezierPathWithRoundedRect:NSMakeRect(irect.origin.x, 
																								 irect.origin.y, 
																								 irect.size.width, 
																								 irect.size.height) 
															xRadius:0.5*irect.size.height
															yRadius:0.5*irect.size.height];
	
	[bp fill];
	[bp release];
	NSSize strSize = [[self attributedStringValue] size];
	NSRect r = NSMakeRect(irect.origin.x+(irect.size.width-strSize.width)/2.0, 
												irect.origin.y-strSize.height/3.0, 
												strSize.width, strSize.height);
	[[self attributedStringValue] drawInRect:r];
	
}

- (NSSize) cellSize
{
	NSAttributedString *str = [self attributedStringValue];
	NSSize strSize = [str size];
	return NSMakeSize(2.0*strSize.width, 0.7*strSize.height);
}




@end
