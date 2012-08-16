//
//  NSString+SectionsOutline.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+SectionsOutline.h"
#import "TPSection.h"
#import "TPSectionTemplate.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "FileEntity.h"
#import "TPFileEntityMetadata.h"
#import "ProjectEntity.h"
#import "MHFileReader.h"

@implementation NSString (SectionsOutline)


- (NSArray*)sectionsInStringForTypes:(NSArray*)templates existingSections:(NSArray*)sections inFile:(id)file
{
  
  // prepare sections found array
  NSMutableArray *sectionsFound = [NSMutableArray array];
  
  // scan for sections
  NSInteger index = 0;
  
  // Gather section commands
  NSMutableArray *sectionCommands = [NSMutableArray array];
  for (TPSectionTemplate *template in templates) {
//    [sectionCommands addObject:template.tag];
    [sectionCommands addObjectsFromArray:template.tags];
  }
  
  NSString *text = self;
  
  // scan text for section commands
  while (index < [text length]) {
    
    // look for section
    if ([text characterAtIndex:index] == '\\') {
      
      if ([text isCommentLineBeforeIndex:index commentChar:@"%"]) {
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange(lineRange);
        continue;
      }
      
      NSUInteger loc = index;
      NSString *word = [text nextWordStartingAtLocation:&loc];
//      NSLog(@"Word: %@", word);
      if ([word beginsWithElementInArray:sectionCommands] != NSNotFound) {
        NSString *command = [word command];
        
        if (command != nil) {
          TPSectionTemplate *template = nil;
          for (TPSectionTemplate *t in templates) {
            for (NSString *tag in t.tags) {
              if ([tag beginsWith:command]) {
                template = t;
                break;
              }
            }
          }
          
          if (template != nil) {
            NSInteger loc = index+1;
            NSString *arg = [text parseArgumentStartingAt:&loc];
            if (arg == nil) {
              arg = template.defaultTitle;
              if (arg == nil) {
                arg = @"<unknown>";
              }
            }
            
            TPSection *section = [TPSection sectionWithParent:nil start:index inFile:file type:template name:arg];
            
            // add the section
            [sectionsFound addObject:section];
          } // end if template is not nil
        } // end if command is not nil        
      } else if ([word beginsWith:@"\\input{"] || [word beginsWith:@"\\include{"]) {
        
        //        NSLog(@"Got include %@", word);
        
        // get argument
        NSString *arg = [word argument];
        __block NSString *subtext = nil;
        __block id subfile = nil;
        if ([file isKindOfClass:[FileEntity class]]) {
          ProjectEntity *project = [(FileEntity*)file project];
          // access the project on the main thread otherwise we can get mutex deadlocks
          dispatch_sync(dispatch_get_main_queue(), ^{
            subfile = [project fileWithPath:arg];
//            NSLog(@"  got file %@", subfile);
            subtext = [subfile workingContentString];
          });
        } else {
          // file is a URL
          NSString *root = [[file path] stringByDeletingLastPathComponent];
          NSString *filepath = [root stringByAppendingPathComponent:arg];
          if ([filepath length] > 0) {
            if ([[filepath pathExtension] isEqualToString:@""]) {
              filepath = [filepath stringByAppendingPathExtension:@"tex"];
            }
          }
          MHFileReader *fr = [[MHFileReader alloc] init];
          subtext = [fr silentlyReadStringFromFileAtURL:[NSURL fileURLWithPath:filepath]];
          if (subtext) 
            subfile = [NSURL fileURLWithPath:filepath];
        }
        if (subtext) {
          NSArray *subsections = [subtext sectionsInStringForTypes:templates existingSections:sections inFile:subfile]; 
          // check if we already have any of these sections
          for (__strong TPSection *ss in subsections) {
            [sectionsFound addObject:ss];
          }
        }
      }
      if (word == nil || [word length] == 0) {
        index++;
      } else {
        index += [word length];
      }
    } else {
      index++;
    }
  }
  
  // now we should replace sections with existing sections, where possible
  
  // replace a section with an existing section if:
  // 1) there is an exact match according to -matches:
  // 2) the order is the same and there is a near match
  NSMutableArray *sectionsToReturn = [NSMutableArray array];
  NSInteger matchIndex = 0;
  for (TPSection *newSection in sectionsFound) {
    BOOL didMatch = NO;
    // check all sections after the last match
    for (NSInteger ii=matchIndex; ii<[sections count]; ii++) {
      TPSection *existingSection = [sections objectAtIndex:ii];
      if ([newSection matches:existingSection] == YES) {
        [sectionsToReturn addObject:existingSection];
//        NSLog(@"Exact match: %@", existingSection);
        didMatch = YES;
        matchIndex = ii+1;
        break;
      }
      
      if ([sectionsFound indexOfObject:newSection] == [sections indexOfObject:existingSection]
          && [existingSection nearlyMatches:newSection] == YES) {
//        NSLog(@"Near match: %@", existingSection);
        [sectionsToReturn addObject:existingSection];
        matchIndex = ii+1;
        didMatch = YES;
        break;        
      }
      
    }
    
    if (didMatch == NO) {
      [sectionsToReturn addObject:newSection];
    }
  }
  
  
  return sectionsToReturn;
}


@end
