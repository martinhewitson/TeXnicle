//
//  BibliographyEntry.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BibliographyEntry : NSObject <NSCoding, NSCopying> {

	NSString *tag;
	NSString *author;
	NSString *title;
	NSString *publishedDate;

	BOOL isObservingKeys;
	
}

@property (readwrite, retain) NSString *tag;
@property (readwrite, retain) NSString *author;
@property (readwrite, retain) NSString *title;
@property (readwrite, retain) NSString *publishedDate;

+ (NSArray*)bibtexEntriesFromString:(NSString*)aString;

- (id) initWithDictionary:(NSDictionary*)entryData;

- (id) initWithString:(NSString*)content;

- (void) setPropertiesFromEntry:(BibliographyEntry*)anEntry;

#pragma mark - 
#pragma mark KVO 
- (void)observeKeys;
- (void) stopObserving;
- (NSArray*) observingKeys;
- (void) parseContentFromString:(NSString*)content;
- (NSString*)parseBibtexField:(NSString*)field fromString:(NSString*)content;
- (NSAttributedString*)attributedString;

- (NSAttributedString*) displayString;
- (NSString*) bibtexEntry;


@end
