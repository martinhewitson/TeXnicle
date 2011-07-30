//
//  NSString+RelativePath.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (RelativePath)


- (NSString*) relativePathTo: (NSString*)endPath;

@end
