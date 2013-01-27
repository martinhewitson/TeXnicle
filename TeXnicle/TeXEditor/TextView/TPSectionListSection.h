//
//  TPSectionListSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/01/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSectionListSection : NSObject

@property (strong) NSString *tag;
@property (strong) NSColor *color;
@property (strong) NSString *regexp;
@property (assign) BOOL isTex;

- (id) initWithTag:(NSString*)tag isTeX:(BOOL)isTex color:(NSColor*)color;

@end
