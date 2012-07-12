//
//  NSString+SectionsOutline.m
//  TeXnicle
//
//  Created by Martin Hewitson on 12/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
    [sectionCommands addObject:template.tag];
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
            if ([t.tag beginsWith:command]) {
              template = t;
            }
          }
          
          if (template != nil) {
            NSInteger loc = index+1;
            NSString *arg = [text parseArgumentStartingAt:&loc];
            if (arg == nil) {
              arg = @"<unknown>";
            }
            
            TPSection *section = [TPSection sectionWithParent:nil start:index inFile:file type:template name:arg];
            
            // if we don't already have this section, we add it
            for (TPSection *s in sections) {
              if ([s matches:section] == YES) {
                section = s; 
              }
            }
            [sectionsFound addObject:section];
          } // end if template is not nil
        } // end if command is not nil        
      } else if ([word beginsWith:@"\\input{"] || [word beginsWith:@"\\include{"]) {
        
        //        NSLog(@"Got include %@", word);
        
        // get argument
        NSString *arg = [word argument];
        NSString *subtext = nil;
        id subfile = nil;
        if ([file isKindOfClass:[FileEntity class]]) {
          ProjectEntity *project = [(FileEntity*)file project];
          subfile = [project fileWithPath:arg];
          subtext = [subfile workingContentString];
        } else {
          // file is a 
          NSString *root = [file stringByDeletingLastPathComponent];
          NSString *filepath = [root stringByAppendingPathComponent:arg];
          if ([[filepath pathExtension] isEqualToString:@""]) {
            filepath = [filepath stringByAppendingPathExtension:@"tex"];
          }
          MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
          subtext = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:filepath]];           
          subfile = filepath;
        }
        NSArray *subsections = [subtext sectionsInStringForTypes:templates existingSections:sections inFile:subfile]; 
        // check if we already have any of these sections
        for (TPSection *ss in subsections) {
          for (TPSection *s in sections) {
            if ([s matches:ss] == YES) {
              ss = s; 
            }
          }
          [sectionsFound addObject:ss];
        }
      }
      index += [word length];
    } else {
      index++;
    }
  }

  return sectionsFound;  
}


@end
