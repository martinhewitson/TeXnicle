//
//  TPSection.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPSectionTemplate;

@interface TPSection : NSObject {
  
  TPSection *parent;
  NSArray *subsections;
  NSUInteger startIndex;
  id file;
  TPSectionTemplate *type;
  NSString *name;
  
}

@property (assign) TPSection *parent;
@property (retain) NSArray *subsections;
@property (assign) NSUInteger startIndex;
@property (retain) id file;
@property (retain) TPSectionTemplate *type;
@property (copy) NSString *name;

+ (id) sectionWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName;
- (id) initWithParent:(TPSection*)aParent start:(NSUInteger)index inFile:(id)aFile type:(TPSectionTemplate*)aType name:(NSString*)aName;
- (BOOL)matches:(id)object;

- (NSAttributedString*)selectedDisplayNameWithDetails;
- (NSAttributedString*)displayNameWithDetails;
- (NSAttributedString*)selectedDisplayName;
- (NSAttributedString*)displayName;


@end
