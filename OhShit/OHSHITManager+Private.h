
#import "OHSHITManager.h"

extern NSString * const OHSHITFilePathKey;

extern NSString * const OHSHITUserStringVariantKey;

extern NSString * const OHSHITUnderlyingErrorKey;

@interface OHSHITManager (Private)

+ (NSArray *)readFailureTypes;

+ (NSArray *)writeFailureTypes;

- (OHSHITStorageFailureType)failureTypeForURL:(NSURL *)inURL matchingFailuresTypes:(NSArray *)inFailuresTypes;

- (OHSHITStorageFailureType)failureTypeForPath:(NSString *)inPath matchingFailuresTypes:(NSArray *)inFailuresTypes;

@end
