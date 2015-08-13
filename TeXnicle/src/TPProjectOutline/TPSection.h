//
//  TPSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPSectionTemplate;

typedef enum TPOutlineExpansionState : NSInteger {
  TPOutlineExpansionStateUnknown = -1,
  TPOutlineExpansionStateCollapse = 0,
  TPOutlineExpansionStateExpanded = 1
} TPOutlineExpansionState;


@interface TPSection : NSObject <NSCopying>

@property (assign) BOOL needsReload;
@property (assign) NSInteger expansionState;
@property (unsafe_unretained) TPSection *parent;
@property (strong) NSArray *subsections;
@property (assign) NSUInteger startIndex;
@property (strong) id file;
@property (strong) TPSectionTemplate *type;
@property (copy) NSString *name;
@property (strong) NSString *filename;

+ (id) sectionWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName;
- (id) initWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName;
- (BOOL)matches:(id)object;
- (BOOL)nearlyMatches:(id)object;

- (NSAttributedString*)selectedDisplayNameWithDetails;
- (NSAttributedString*)displayNameWithDetails;
- (NSAttributedString*)selectedDisplayName;
- (NSAttributedString*)displayName;


@end
