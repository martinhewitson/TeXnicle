//
//  TPCitationsViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
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

#import "TPCitationsViewController.h"
#import "externs.h"
#import "TPCitationSet.h"
#import "BibliographyEntry.h"
#import "TPCitation.h"

@interface TPCitationsViewController ()

@end

@implementation TPCitationsViewController

- (void) updateUI
{
  NSArray *newFiles = [self metadataViewListOfFiles:self];
  if (newFiles == nil) {
    newFiles = @[];
  }
  
  // remove any stale files
  NSMutableArray *filesToRemove = [NSMutableArray array];
  for (TPCitationSet *set in self.sets) {
    if ([newFiles containsObject:set.file] == NO) {
      [filesToRemove addObject:set];
    }
  }
  [self.sets removeObjectsInArray:filesToRemove];
  
  // update our files
  for (TPFileMetadata *newFile in newFiles) {
    TPMetadataSet *set = [self setForFile:newFile];
    if (set == nil) {
      NSArray *entries = [self metadataView:self newItemsForFile:newFile];
      if (entries && [entries count] > 0) {
        set = [[TPCitationSet alloc] initWithFile:newFile items:entries];
        [self.sets addObject:set];
      }
    } else {
      // update the citations
      NSArray *newCitations = [self metadataView:self newItemsForFile:newFile];
      [(TPCitationSet*)set setCitationsFromBibliographyArray:newCitations];
    }
  }
  
  [super updateUI];
}

#pragma mark -
#pragma mark OutlineView delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
  NSString *tags = @"";
  for (id item in items) {
    if ([item isKindOfClass:[TPMetadataSet class]]) {
      return NO;
    }
    
    TPMetadataItem *metaitem = (TPMetadataItem*)item;
    NSString *tag = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(metadataView:dragStringForItem:)]) {
      tag = [self.delegate metadataView:self dragStringForItem:metaitem];
      if (tag == nil) {
        return NO;
      }
    } else {
      tag = [self dragStringForItem:metaitem];
    }
    
    if ([tags length] > 0) {
      tags = [tags stringByAppendingFormat:@", %@", tag];
    } else {
      tags = tag;
    }
  }
  
  NSString *dragString = [NSString stringWithFormat:@"\\cite{%@}", tags];
  
  [pasteboard declareTypes:@[NSPasteboardTypeString] owner:self];
  return [pasteboard setString:dragString forType:NSPasteboardTypeString];
}

- (NSString*) dragStringForItem:(id)item
{
  if ([item isKindOfClass:[TPCitation class]]) {
    TPCitation *cite = (TPCitation*)item;
    BibliographyEntry *entry = cite.entry;
    return [NSString stringWithFormat:@"%@", entry.tag];
  }
  
  return nil;
}

@end


