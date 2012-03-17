//
//  TechReport.m
//  TeXnicle
//
//  Created by Martin Hewitson on 3/4/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
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
