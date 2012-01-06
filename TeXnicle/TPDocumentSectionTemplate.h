//
//  TPDocumentSectionTemplate.h
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDocumentSectionTemplate : NSObject {
@private
  NSString *tag;
  NSString *name;
  NSInteger order;
}

@property (copy) NSString *tag;
@property (copy) NSString *name;
@property (assign) NSInteger order;

+ (TPDocumentSectionTemplate*)documentSectionTemplateWithName:(NSString*)aName tag:(NSString*)aTag order:(NSInteger)anOrder;
- (id) initWithName:(NSString*)aName tag:(NSString*)aTag order:(NSInteger)anOrder;


@end
