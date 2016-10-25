/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OHSHITManager.h"

#import "RegexKitLite.h"

NSString * const OHSHITStorageLocationKey=@"Location";

NSString * const OHSHITStorageFailureTypeKey=@"Type";

NSString * const OHSHITStoragePathAll=@"/";

@interface OHSHITManager ()
{
	NSMutableDictionary * _failuresRegistry;
}

@end

@implementation OHSHITManager

+ (instancetype)defaultManager
{
	static OHSHITManager * sOHSHITManager = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sOHSHITManager = [[OHSHITManager alloc] init];
	});
	
	return sOHSHITManager;
}

#pragma mark -

- (void)setStorageFailuresList:(NSArray *)inFailuresList
{
	_failuresRegistry=[NSMutableDictionary dictionary];
	
	[inFailuresList enumerateObjectsUsingBlock:^(NSDictionary *bFailureCase,NSUInteger bIndex,BOOL * boutStop){
	
		NSNumber * tFailureTypeNumber=bFailureCase[OHSHITStorageFailureTypeKey];
		
		if (tFailureTypeNumber==nil)
			return;
		
		OHSHITStorageLocation * tStorageLocation=bFailureCase[OHSHITStorageLocationKey];
		
		if (tStorageLocation==nil)
			return;
		
		NSMutableSet * tMutableLocationsSet=_failuresRegistry[tFailureTypeNumber];
		
		if (tMutableLocationsSet==nil)
		{
			tMutableLocationsSet=_failuresRegistry[tFailureTypeNumber]=[NSMutableSet set];
		}
		
		[tMutableLocationsSet addObject:tStorageLocation];
	}];
}

#pragma mark -

+ (NSArray *)readFailureTypes
{
	return @[@(OHSHIT_StorageSimulateFileMissingIntermediaryDirectory),@(OHSHIT_StorageSimulateFileNotFound),@(OHSHITStorageSimulateEmptyFile),@(OHSHITStorageSimulateRandomContents)];
}

+ (NSArray *)writeFailureTypes
{
	return @[@(OHSHIT_StorageSimulateFileMissingIntermediaryDirectory),@(OHSHIT_StorageSimulateNoMoreSpace),@(OHSHIT_StorageSimulateReadOnly),@(OHSHIT_StorageSimulateFileWritePermissionDenied)];
}

#pragma mark -

- (OHSHITStorageFailureType)failureTypeForURL:(NSURL *)inURL matchingFailuresTypes:(NSArray *)inFailuresTypes
{
	if ([inURL isFileURL]==NO)
		return OHSHIT_StorageNoSimulatedFailure;
	
	return [self failureTypeForPath:[inURL path] matchingFailuresTypes:inFailuresTypes];
}

- (OHSHITStorageFailureType)failureTypeForPath:(NSString *)inPath matchingFailuresTypes:(NSArray *)inFailuresTypes
{
	for(NSNumber * tFailureTypeNumber in inFailuresTypes)
	{
		NSSet * tStorageLocations=_failuresRegistry[tFailureTypeNumber];
		
		OHSHITStorageFailureType tFailureType=[tFailureTypeNumber unsignedIntegerValue];
		
		for(OHSHITStorageLocation * tStorageLocation in tStorageLocations)
		{
			if (tStorageLocation.regularExpression==YES)
			{
				if ([inPath isMatchedByRegex:tStorageLocation.pattern options:RKLNoOptions inRange:((NSRange){0, NSUIntegerMax}) error:NULL]==YES)
					return tFailureType;
				
				continue;
			}
			
			if ([tStorageLocation.pattern hasSuffix:@"/"]==YES)
			{
				if ([inPath hasPrefix:tStorageLocation.pattern]==YES)
					return tFailureType;
				
				continue;
			}
			
			if ([inPath caseInsensitiveCompare:tStorageLocation.pattern]==NSOrderedSame)
				return tFailureType;
		}
	}
	
	return OHSHIT_StorageNoSimulatedFailure;
}

@end
