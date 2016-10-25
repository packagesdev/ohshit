/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OHSHITStorageLocation.h"

NSString * const OHSHITStorageLocationPathKey=@"Path";

NSString * const OHSHITStorageLocationPatternKey=@"Pattern";

@implementation OHSHITStorageLocation

+ (instancetype)storageLocationWithPath:(NSString *)inPath
{
	return [[OHSHITStorageLocation alloc] initWithPath:inPath];
}

+ (instancetype)storageLocationWithPattern:(NSString *)inPattern
{
	return [[OHSHITStorageLocation alloc] initWithPattern:inPattern];
}

- (instancetype)initWithRepresentation:(NSDictionary *)inRepresentation
{
	if (inRepresentation==nil || [inRepresentation isKindOfClass:[NSDictionary class]]==NO)
		return nil;
	
	self=[super init];
	
	if (self!=nil)
	{
		NSString * tString=inRepresentation[OHSHITStorageLocationPathKey];
		
		if (tString!=nil)
		{
			if ([tString isKindOfClass:[NSString class]]==NO)
				return nil;
			
			_pattern=[tString copy];
			
			_regularExpression=NO;
			
			return self;
		}
		
		tString=inRepresentation[OHSHITStorageLocationPatternKey];
		
		if (tString!=nil)
		{
			if ([tString isKindOfClass:[NSString class]]==NO)
				return nil;
			
			_pattern=[tString copy];
			
			_regularExpression=YES;
			
			return self;
		}
	}
	
	return nil;
}

- (instancetype)initWithPath:(NSString *)inPath
{
	if (inPath==nil || [inPath isKindOfClass:[NSString class]]==NO)
		return nil;
	
	self=[super init];
	
	if (self!=nil)
	{
		_pattern=[inPath copy];
		
		_regularExpression=NO;
	}
	
	return self;
}

- (instancetype)initWithPattern:(NSString *)inPattern
{
	if (inPattern==nil || [inPattern isKindOfClass:[NSString class]]==NO)
		return nil;
	
	self=[super init];
	
	if (self!=nil)
	{
		_pattern=[inPattern copy];
		
		_regularExpression=YES;
	}
	
	return self;
}

@end
