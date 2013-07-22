//
//  TPDocumentSectionManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDocumentSectionManager : NSObject


@property (strong) NSArray *templates;
@property (readonly) NSArray *sectionNames;
@property (readonly) NSArray *sectionCommands;

+ (TPDocumentSectionManager*)sharedSectionManager;

- (NSArray*) tagsForSection:(NSString*)section;
- (void) setTags:(NSArray*)tags forSection:(NSString*)section;

- (void) setColor:(NSColor*)color forName:(NSString*)name;
- (void) handleThemeDidChangeNotification:(NSNotification*)aNote;

@end
