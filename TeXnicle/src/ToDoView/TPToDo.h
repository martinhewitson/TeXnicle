//
//  TPToDo.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPMetadataItem.h"

@interface TPToDo : TPMetadataItem

@property (copy) NSString *text;

+ (id) toDoWithFile:(id)aFile text:(NSString*)aString;
- (id) initWithFile:(id)aFile text:(NSString*)aString;

- (NSString*)string;

@end
