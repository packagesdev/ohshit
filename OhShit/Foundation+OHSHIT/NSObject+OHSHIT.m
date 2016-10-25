/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* Some code is borrowed from the nshipster blog. So the above BSD license does not apply for the marked methods. */

#import "NSObject+OHSHIT.h"

#include <objc/runtime.h>

@interface NSObject (OHSHIT_Private)

+ (void)OHSHIT_Swizzle:(SEL)inOriginalSelector with:(SEL)inSHITSelector;

@end


@implementation NSObject (OHSHIT)

// Code borrowed from http://nshipster.com/method-swizzling/

+ (void)OHSHIT_Swizzle:(SEL)inOriginalSelector with:(SEL)inSHITSelector
{
	Class tClass=[self class];
	
	Method originalMethod = class_getInstanceMethod(tClass, inOriginalSelector);
	Method swizzledMethod = class_getInstanceMethod(tClass, inSHITSelector);
	
	// When swizzling a class method, use the following:
	// Class class = object_getClass((id)self);
	// ...
	// Method originalMethod = class_getClassMethod(class, inOriginalSelector);
	// Method swizzledMethod = class_getClassMethod(class, inSHITSelector);
	
	BOOL didAddMethod =
	class_addMethod(tClass,
					inOriginalSelector,
					method_getImplementation(swizzledMethod),
					method_getTypeEncoding(swizzledMethod));
	
	if (didAddMethod==YES)
	{
		class_replaceMethod(tClass,
							inSHITSelector,
							method_getImplementation(originalMethod),
							method_getTypeEncoding(originalMethod));
	}
	else
	{
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
}

+ (BOOL)OHSHIT_start
{
	// Class Methods
	
	// A COMPLETER
	
	// Instance Methods
	
	Class tClass=[self class];
	
	unsigned int tMethodCount = 0;
	
	Method *tMethods = class_copyMethodList(tClass, &tMethodCount);
	
	for (unsigned int i = 0; i < tMethodCount; i++)
	{
		Method tMethod = tMethods[i];
		
		NSString * tOriginalSelectorString=[NSString stringWithUTF8String:sel_getName(method_getName(tMethod))];
		NSString * tSHITSelectorString=[@"OHSHIT_" stringByAppendingString:tOriginalSelectorString];
		
		SEL tSHITSelector=NSSelectorFromString(tSHITSelectorString);
		
		if ([tClass instancesRespondToSelector:tSHITSelector]==YES)
		{
			SEL tOriginalSelector=NSSelectorFromString(tOriginalSelectorString);
			
			[tClass OHSHIT_Swizzle:tOriginalSelector with:tSHITSelector];
		}
	}
	
	return YES;
}

+ (BOOL)OHSHIT_stop
{
	return YES;
}

@end
