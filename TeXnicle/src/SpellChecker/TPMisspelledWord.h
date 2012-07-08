//
//  TPMisspelledWord.h
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPSpellCheckedFile;

@interface TPMisspelledWord : NSObject {
  NSString *word;
  NSArray *corrections;
  NSRange range;
  TPSpellCheckedFile *parent;
}

@property (copy) NSString *word;
@property (copy) NSArray *corrections;
@property (assign) NSRange range;
@property (assign) TPSpellCheckedFile *parent;

+ (TPMisspelledWord*) wordWithWord:(NSString*)aWord corrections:(NSArray*)correctionList range:(NSRange)aRange parent:(TPSpellCheckedFile*)aParent;
- (id) initWithWord:(NSString*)aWord corrections:(NSArray*)correctionList range:(NSRange)aRange parent:(TPSpellCheckedFile*)aParent;
- (NSString*)displayString;

@end
