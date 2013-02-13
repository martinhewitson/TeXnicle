//
//  NSAttributedString+Placeholders.h
//  TeXnicle
//
//  Created by Martin Hewitson on 31/1/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Placeholders)

+ (NSAttributedString*) stringWithPlaceholdersRestored:(NSString*)string;
+ (NSAttributedString*) stringWithPlaceholdersRestored:(NSString*)string attributes:(NSDictionary*)attributes;

- (NSAttributedString*) replacePlaceholders;
- (NSAttributedString*) replacePlaceholders:(NSRange)range;

@end
