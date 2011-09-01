//
//  NSString+FileTypes.h
//  TeXnicle
//
//  Created by Martin Hewitson on 17/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileTypes)

- (BOOL)isImage;
- (BOOL)isText;
- (BOOL)pathIsImage;
- (BOOL)pathIsText;

@end
