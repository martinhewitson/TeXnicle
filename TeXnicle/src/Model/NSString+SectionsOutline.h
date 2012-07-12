//
//  NSString+SectionsOutline.h
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SectionsOutline)

- (NSArray*)sectionsInStringForTypes:(NSArray*)templates existingSections:(NSArray*)sections inFile:(id)file;

@end
