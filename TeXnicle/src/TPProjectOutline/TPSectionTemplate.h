//
//  TPSectionTemplate.h
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSectionTemplate : NSObject

@property (copy) NSString *tag;
@property (copy) NSString *name;
@property (unsafe_unretained) TPSectionTemplate *parent;
@property (strong) NSColor *color;
@property (copy) NSString *mnemonic;

+ (id) documentSectionTemplateWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate*)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName;
- (id) initWithName:(NSString*)aName tag:(NSString*)aTag parent:(TPSectionTemplate*)aParent color:(NSColor*)aColor mnemonic:(NSString*)shortName;

+ (BOOL) template:(TPSectionTemplate*)t1 isChildOf:(TPSectionTemplate*)t2; 
- (NSInteger) depth;


@end
