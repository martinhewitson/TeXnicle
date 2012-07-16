//
//  TechReport.m
//  TeXnicle
//
//  Created by Martin Hewitson on 1/4/10.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TechReport.h"
#import "NSMutableAttributedString+BibFieldDisplay.h"

@implementation TechReport

@synthesize month;
@synthesize number;

- (id)init
{
	self = [super init];
	
	if (self) {
		[self setMonth:@""];
		[self setNumber:@""];
	}
	
	return self;
}

- (id) initWithDictionary:(NSDictionary*)entryData
{
	self = [super initWithDictionary:entryData];
	
	if (self) {
		
		[self setMonth:@""];
		[self setNumber:@""];
		
		NSString *str = [entryData valueForKey:@"Month"];
		if (str) 
			[self setMonth:str];
		
		str = [entryData valueForKey:@"Number"];
		if (str)
			[self setNumber:str];
		
		[self observeKeys];
		
	}
	
	return self;
}

- (void) dealloc
{
	[self stopObserving];
	[super dealloc];
}

#pragma mark -
#pragma mark KVO 

- (void)observeKeys
{
	
	for (NSString *key in [self observingKeys]) {
		[self addObserver:self 
					 forKeyPath:key
							options:NSKeyValueObservingOptionNew 
							context:NULL];
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
											ofObject:(id)object
												change:(NSDictionary *)change 
											 context:(void *)context
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:TPBibliographyChangedNotification object:self];
}

- (void) stopObserving
{
	for (NSString *key in [self observingKeys]) {
		[self removeObserver:self forKeyPath:key];
	}	
}

- (NSArray*) observingKeys
{
	return [[super observingKeys] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"number", @"month", nil]];
}

#pragma mark -
#pragma mark Encoding/decoding

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	number = [[coder decodeObjectForKey:@"number"] retain];
	month = [[coder decodeObjectForKey:@"month"] retain];
	[self observeKeys];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:month forKey:@"month"];
	[coder encodeObject:number forKey:@"number"];
}


- (NSAttributedString*) displayString
{
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithAttributedString:[super displayString]] autorelease];
	
	NSString *vstr = [self month];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Month:"];
	
	vstr = [self number];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Number:"];
	
	return str;
}

- (id)copyWithZone:(NSZone *)zone
{
	TechReport *copy = [super copyWithZone:zone];
	
	[copy setMonth:[self month]];
	[copy setNumber:[self number]];
	
	return copy;
}

- (NSString*) bibtexEntry
{
	NSMutableString *str = [NSMutableString stringWithString:@"@techreport{"];
	
	// add tag
	NSString *vstr = [self tag];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"%@,\n", vstr];
	
	// add author
	vstr = [self author];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tAuthor={%@},\n", vstr];
	
	// add title 
	vstr = [self title];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tTitle={%@},\n", vstr];
	
	// add published
	vstr = [self publishedDate];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tYear={%@},\n", vstr];
	
	// add month
	vstr = [self month];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tMonth={%@},\n", vstr];
	
	// add number
	vstr = [self number];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tNumber={%@}", vstr];
	
	[str appendFormat:@"}"];
	
	
	return [NSString stringWithString:str];
}


- (void) setPropertiesFromEntry:(TechReport*)anEntry
{
	[super setPropertiesFromEntry:anEntry];
	
	[self setMonth:[anEntry month]];
	[self setNumber:[anEntry number]];
	
}


@end
