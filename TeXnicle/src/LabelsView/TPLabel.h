//
//  TPLabel.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPLabel : NSObject

@property (copy) NSString *text;
@property (unsafe_unretained) id file;

+ (id) labelWithFile:(id)aFile text:(NSString*)aString;
- (id) initWithFile:(id)aFile text:(NSString*)aString;

- (NSString*)string;

@end
