//
//  TPRegularExpression.h
//  TeXnicle
//
//  Created by Martin Hewitson on 13/10/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPRegularExpression : NSObject

+ (NSArray*)rangesMatching:(NSString*)expr inText:(NSString*)text;
+ (NSArray*)stringsMatching:(NSString*)expr inText:(NSString*)text;
+ (NSRange)rangeOfExpr:(NSString*)expr inText:(NSString*)text;
+ (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)expr withString:(NSString*)replacement inString:(NSString*)text;
+ (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)expr inRange:(NSRange)aRange withString:(NSString*)replacement inString:(NSString*)text;

@end
