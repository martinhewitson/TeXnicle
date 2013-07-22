//
//  NSDictionary+Theme.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Theme)

- (NSColor*)colorForKey:(NSString*)aKey;
- (NSArray*)sortedKeys;

@end
