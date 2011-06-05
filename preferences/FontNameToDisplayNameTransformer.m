
#import "FontNameToDisplayNameTransformer.h"

/*
 Takes as input the fontName of a font as stored in user defaults,
 returns the displayed font name of the font to show to the user.
 */

@implementation FontNameToDisplayNameTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
	NSFont *font = [NSUnarchiver unarchiveObjectWithData:aValue];
	return [NSString stringWithFormat:@"%@ - %2.1fpt", [font displayName], [font pointSize]];
}


@end
