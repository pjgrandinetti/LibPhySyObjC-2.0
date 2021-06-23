//
//  PSCFString.c
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import <math.h>
#import <complex.h>
#import <stdbool.h>
#import <unistd.h>
#import "CFAdditions.h"

void PSCFStringShow(CFStringRef string)
{
    if(string==NULL) return;
    if(CFGetTypeID(string) != CFStringGetTypeID()) return;
    
    CFIndex length = CFStringGetMaximumSizeForEncoding(CFStringGetLength(string),kCFStringEncodingUTF8) +1;
    if(length) {
        char *cString = malloc(length*2);
        CFStringGetCString(string, cString, length, kCFStringEncodingUTF8);
        fprintf(stdout,"%s\n",cString);
        fflush(stdout);
        free(cString);
    }
}

char *CreateCString2(CFStringRef string)
{
    if(string==NULL) return NULL;
    CFIndex length = CFStringGetLength(string);
    char *cString = malloc(length+1);
    for(CFIndex i=0;i<length;i++) {
        UniChar uniChar = CFStringGetCharacterAtIndex(string, i);
        cString[i] = uniChar;
    }
    cString[length] = 0;
    return cString;
}

char *CreateCString(CFStringRef string)
{
    if(string==NULL) return NULL;
    char *cString = NULL;
    CFIndex length = CFStringGetMaximumSizeForEncoding(CFStringGetLength(string),kCFStringEncodingUTF8) +1;
    if(length) {
        cString = malloc(length*2);
        CFStringGetCString(string, cString, length, kCFStringEncodingUTF8);
    }
    return cString;
}

bool characterIsUpperCaseLetter(UniChar character)
{
    if(character>='A'&&character<='Z') return YES;
    return NO;
}

bool characterIsLowerCaseLetter(UniChar character)
{
    if(character>='a'&&character<='z') return YES;
    return NO;
}

bool characterIsDigitOrDecimalPoint(UniChar character)
{
    if(character>='0'&&character<='9') return YES;
    if(character=='.') return YES;
    return NO;
}

bool characterIsDigitOrDecimalPointOrMinus(UniChar character)
{
    if(character>='0'&&character<='9') return YES;
    if(character=='.') return YES;
    if(character=='-') return YES;
    return NO;
}

bool characterIsDigitOrDecimalPointOrSpace(UniChar character)
{
    if(character>='0'&&character<='9') return YES;
    if(character=='.' || character==' ') return YES;
    return NO;
}


CFComparisonResult PSStringCompareStringLengths (const void *val1, const void *val2, void *context)
{
    CFStringRef string1 = (CFStringRef) val1;
    CFStringRef string2 = (CFStringRef) val2;
    if(CFStringGetLength(string1) > CFStringGetLength(string2)) return kCFCompareLessThan;
    if(CFStringGetLength(string1) < CFStringGetLength(string2)) return kCFCompareGreaterThan;
    return kCFCompareEqualTo;
}


UniChar PSCFStringGetCharacterAtIndex(CFStringRef theString, CFIndex index)
{
    CFIndex length = CFStringGetLength(theString);
    if(index>=0 && index<length) return CFStringGetCharacterAtIndex(theString, index);
    else {
        fprintf(stderr, "Attempt to get character at index=%ld beyond range of 0 to %ld",index,length-1);
        CFShow(theString);
        return 0;
    }
}

bool PSCFStringTrimMatchingQuotes(CFMutableStringRef theString)
{
    // This method eliminates matching \" from strings,
    CFIndex length = CFStringGetLength(theString);
    
    UniChar quoteChar = 8220;
    CFStringRef quote = CFStringCreateWithCharacters(kCFAllocatorDefault, &quoteChar, 1);
    CFStringFindAndReplace(theString, quote, CFSTR("\""), CFRangeMake(0, CFStringGetLength(theString)), 0);
    CFRelease(quote);
    
    quoteChar = 8221;
    quote = CFStringCreateWithCharacters(kCFAllocatorDefault, &quoteChar, 1);
    CFStringFindAndReplace(theString, quote, CFSTR("\""), CFRangeMake(0, CFStringGetLength(theString)), 0);
    CFRelease(quote);

    if(length<2) return false;
    UniChar firstCharacter =  PSCFStringGetCharacterAtIndex(theString,0);
    UniChar lastCharacter =  PSCFStringGetCharacterAtIndex(theString,length-1);
    
    UniChar quoteCharacter = '\"';
    
    CFStringTrimWhitespace(theString);
    if(firstCharacter != quoteCharacter || lastCharacter != quoteCharacter) return false;
    CFMutableStringRef mutString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, theString);
    CFIndex trim = -1;
    
    while(firstCharacter == quoteCharacter && lastCharacter == quoteCharacter) {
        trim++;
        CFStringDelete(mutString, CFRangeMake(length-1, 1));
        CFStringDelete(mutString, CFRangeMake(0, 1));
        length = CFStringGetLength(mutString);
        
        firstCharacter =  PSCFStringGetCharacterAtIndex(mutString,0);
        lastCharacter =  PSCFStringGetCharacterAtIndex(mutString,length-1);
    }
    CFRelease(mutString);
    
    if(trim == -1) return false;
    for(CFIndex i = 0; i<trim+1; i++) {
        length = CFStringGetLength(theString);
        CFStringDelete(theString, CFRangeMake(length-1, 1));
        CFStringDelete(theString, CFRangeMake(0, 1));
    }
    return true;

}

bool PSCFStringTrimMatchingParentheses(CFMutableStringRef theString)
{
    // This method eliminates superfluous parentheses from strings, e.g. ((4+5)) reduces to (4+5)
    CFIndex length = CFStringGetLength(theString);
    if(length<2) return false;
    UniChar firstCharacter =  PSCFStringGetCharacterAtIndex(theString,0);
    UniChar lastCharacter =  PSCFStringGetCharacterAtIndex(theString,length-1);
    
    if(firstCharacter != '(' || lastCharacter != ')') return false;
    CFMutableStringRef mutString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, theString);
    CFIndex trim = -1;
    while(firstCharacter == '(' && lastCharacter == ')') {
        trim++;
        CFStringDelete(mutString, CFRangeMake(length-1, 1));
        CFStringDelete(mutString, CFRangeMake(0, 1));
        length = CFStringGetLength(mutString);
        
        firstCharacter =  PSCFStringGetCharacterAtIndex(mutString,0);
        lastCharacter =  PSCFStringGetCharacterAtIndex(mutString,length-1);
    }
    CFRelease(mutString);
    
    if(trim == 0) return false;
    for(CFIndex i = 0; i<trim; i++) {
        length = CFStringGetLength(theString);
        CFStringDelete(theString, CFRangeMake(length-1, 1));
        CFStringDelete(theString, CFRangeMake(0, 1));
    }
    return true;
}


bool PSCFStringIsEnclosedInParentheses(CFStringRef theString)
{
    // This method determines if string expression is enclosed in parentheses,
    // e.g. (4•(5+6)•7) is enclosed, but (4+5)(6+7) is not.
    
    CFIndex length = CFStringGetLength(theString);
    if(length<2) return false;
    UniChar firstCharacter =  PSCFStringGetCharacterAtIndex(theString,0);
    UniChar lastCharacter =  PSCFStringGetCharacterAtIndex(theString,length-1);
    
    if(firstCharacter != '(' || lastCharacter != ')') return false;

    // If string is enclosed in parentheses then sum should never go to zero inside string.
    CFIndex sum = 1;
    for(CFIndex index = 1;index<length-1; index++) {
        UniChar character =  PSCFStringGetCharacterAtIndex(theString,index);
        if(character == '(') sum++;
        if(character == ')') sum--;
        if(sum<=0) return false;
    }
    
    return true;
}

long unsigned PSCFStringGetLongUnsignedInt(CFStringRef theString, bool *success)
{
    if(theString==NULL) return 0;
    char *cString = CreateCString(theString);
    long unsigned value;
    *success = true;
    if(sscanf(cString, "%lu",&value)==0) {
        *success = false;
        if(cString) free(cString);
        return 0;
    }
    if(cString) free(cString);
    return value;
}

CFMutableStringRef PSCFMutableStringCreateWithCString(CFAllocatorRef alloc, const char *cStr, CFIndex maxLength, CFStringEncoding encoding)
{
    CFStringRef string = CFStringCreateWithCString(alloc,cStr,encoding);
    CFMutableStringRef mutableString = CFStringCreateMutableCopy(alloc, maxLength, string);
    CFRelease(string);
    return mutableString;
}

float complex PSCFStringGetFloatComplexFromCommaSeparatedParts(CFStringRef theString) {
    if(theString==NULL) return nan("0");
    CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(theString),theString);
    CFStringFindAndReplace (mutString,CFSTR(","), CFSTR("+I*"),CFRangeMake(0,CFStringGetLength(mutString)),0);
    float complex value = PSCFStringGetFloatComplexValue(mutString);
    CFRelease(mutString);
    return value;
}

double complex PSCFStringGetDoubleComplexFromCommaSeparatedParts(CFStringRef theString) {
    if(theString==NULL) return nan("0");
    CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(theString),theString);
    CFStringFindAndReplace (mutString,CFSTR(","), CFSTR("+I*"),CFRangeMake(0,CFStringGetLength(mutString)),0);
    double complex value = PSCFStringGetDoubleComplexValue(mutString);
    CFRelease(mutString);
    return value;
}

float complex PSCFStringGetFloatComplexValue(CFStringRef string)
{
    if(string==NULL) return nan("0");
    
    CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(string),string);
    CFStringFindAndReplace (mutString,CFSTR("•"), CFSTR("*"),CFRangeMake(0,CFStringGetLength(mutString)),0);
    CFIndex length = CFStringGetMaximumSizeForEncoding(CFStringGetLength(mutString),kCFStringEncodingUTF8) +1;
    
    char *cString = malloc(length*2);
    CFStringGetCString(mutString, cString, length, kCFStringEncodingUTF8);
    float complex result = PSComplexFromCString(cString);
    
    free(cString);
    CFRelease(mutString);
    return result;
}

double complex PSCFStringGetDoubleComplexValue(CFStringRef string)
{
    if(string==NULL) return nan("0");
    
    CFMutableStringRef  mutString = CFStringCreateMutableCopy ( kCFAllocatorDefault,CFStringGetLength(string),string);
    CFStringFindAndReplace (mutString,CFSTR("•"), CFSTR("*"),CFRangeMake(0,CFStringGetLength(mutString)),0);
    CFIndex length = CFStringGetMaximumSizeForEncoding(CFStringGetLength(mutString),kCFStringEncodingUTF8) +1;
    
    char *cString = malloc(length*2);
    CFStringGetCString(mutString, cString, length, kCFStringEncodingUTF8);
    double complex result = PSComplexFromCString(cString);
    
    free(cString);
    CFRelease(mutString);
    return result;
}

CFRange PSCFStringRangeOfMostConsecutiveDigits(CFStringRef numericString, UniChar digit)
{
    // Find range of consecutive nines
    CFRange range = CFStringFind(numericString, CFSTR("e"), 0);
    if(range.location == kCFNotFound) range.location = CFStringGetLength(numericString);
    CFIndex lastDigitPosition = range.location;

    CFRange ranges[10];
    CFIndex rangeIndex = 0;
    bool lastDigitWasNineOrDecimal = false;
    ranges[rangeIndex].location = kCFNotFound;
    ranges[rangeIndex].length = 0;
    for(CFIndex index=0; index<lastDigitPosition; index++) {
        UniChar character = PSCFStringGetCharacterAtIndex(numericString, index);
        if(character == '9' || character == '.') {
            if(!lastDigitWasNineOrDecimal) {
                ranges[rangeIndex].location = index;
                ranges[rangeIndex].length = 1;
                rangeIndex++;
            }
            else ranges[rangeIndex-1].length++;
            lastDigitWasNineOrDecimal = true;
        }
        else lastDigitWasNineOrDecimal = false;
    }
    CFRange bestRange = {kCFNotFound,0};
    for(CFIndex index=0;index<rangeIndex;index++) {
        CFRange range = ranges[index];
        if(range.length>bestRange.length) bestRange = range;
    }
    return bestRange;
}

CFStringRef PSCFStringCreateStringWithRoundedNumber2(CFStringRef numericString)
{
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(numericString), numericString);
    double value = CFStringGetDoubleValue(numericString);
    CFRange range = CFStringFind(string, CFSTR("e"), 0);
    if(range.location == kCFNotFound) range.location = CFStringGetLength(string);
    CFIndex lastDigitPosition = range.location;

    CFRange ninesRange = PSCFStringRangeOfMostConsecutiveDigits(string, '9');
    if(ninesRange.length > 4) {
        CFRange periodRange = CFStringFind(string, CFSTR("."), 0);
        CFRange fullRange = ninesRange;
        fullRange.length = lastDigitPosition - fullRange.location;
        CFStringDelete(string, fullRange);
        if(ninesRange.location>0) {
            UniChar preNine = PSCFStringGetCharacterAtIndex(string, ninesRange.location-1);
            if(preNine != '9' || preNine != '.') {
                preNine++;
                CFStringRef digit = CFStringCreateWithCharacters(kCFAllocatorDefault, &preNine, 1);
                CFStringReplace(string, CFRangeMake(ninesRange.location-1, 1), digit);
                CFRelease(digit);
                for(CFIndex index=ninesRange.location;index<periodRange.location;index++) CFStringAppend(string, CFSTR("0"));
            }
        }
    }
    
    double roundedValue = CFStringGetDoubleValue(string);
    if(PSCompareDoubleValues(value, roundedValue)==kPSCompareEqualTo) return string;
    CFRelease(string);
    return CFRetain(numericString);
}

CFStringRef PSCFStringCreateStringWithRoundedNumber(CFStringRef numericString)
{
    CFMutableStringRef string = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(numericString), numericString);
    
    double value = CFStringGetDoubleValue(numericString);
    
    CFRange range = CFStringFind(string, CFSTR("e"), 0);
    if(range.location == kCFNotFound) range.location = CFStringGetLength(string);
    CFIndex lastDigitPosition = range.location;
    
    CFIndex index = range.location-2;
    if(index<0) {
        CFRelease(string);
        return CFRetain(numericString);
    }
    
    CFIndex count = -1;
    UniChar character;
    do {
        character = PSCFStringGetCharacterAtIndex(string, index--);
        count++;
    } while((character=='9'||character=='.') && index >= 0);
    
    if(count>3) {
        index++;  // index now points to digit y
        CFRange periodRange = CFStringFind(string, CFSTR("."), 0);
        if(periodRange.location == kCFNotFound  || periodRange.location <=index) {
            // This looks like   x.xxxy999999
            // Need to change to x.xxx(y+1)
            
            // Next we eliminate all the trailing nines
            range.location = index+1;
            range.length = count+1;
            CFStringDelete(string, range);
            
            // round up y to next integer and replace
            character++;
            CFStringRef digit = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
            range.location= index;
            range.length = 1;
            if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
            CFStringReplace(string, range, digit);
            CFRelease(digit);
        }
        else if(index==0) {
            // Something like y9999.9999...
            character = PSCFStringGetCharacterAtIndex(string, index);
            if(character!='9') {
                character++;
                CFStringRef digit = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
                range.location= index;
                range.length = 1;
                CFStringReplace(string, range, digit);
                CFRelease(digit);
                for(CFIndex zero=index+1;zero<periodRange.location;zero++) CFStringReplace(string, CFRangeMake(zero, 1), CFSTR("0"));
                // Next we eliminate all the trailing nines
                range.location = periodRange.location;
                range.length = lastDigitPosition - periodRange.location;
                if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
                CFStringDelete(string, range);
            }
            else {
                // Something like 99999.9999...
                // Find decimal
                CFRange periodRange = CFStringFind(string, CFSTR("."), 0);
                CFStringDelete(string, CFRangeMake(0, CFStringGetLength(string)));
                CFStringAppend(string, CFSTR("1"));
                for(CFIndex j=0;j<periodRange.location;j++) {
                    CFStringAppend(string, CFSTR("0"));
                }
            }
        }
        else {
            character = PSCFStringGetCharacterAtIndex(string, index);
            if(character == 46) {
                index--;  // character at index is '.', and character before '.' is what we need to round
                character = PSCFStringGetCharacterAtIndex(string, index);
            }
            
            // This looks like y.99999999...
            // need to change to (y+1)
            // index = 0 and now points to digit y
            
            // Next we eliminate all the trailing nines and decimal point
            range.length = range.location - periodRange.location;
            range.location = periodRange.location;
            CFStringDelete(string, range);
            
            // round up y to next integer and replace
            if(character !='9') {
                character++;
                CFStringRef digit = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
                range.location= index;
                range.length = 1;
                if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
                CFStringReplace(string, range, digit);
                CFRelease(digit);
                for(CFIndex zero=index+1;zero<periodRange.location;zero++) {
                    CFStringReplace(string, CFRangeMake(zero, 1), CFSTR("0"));
                }
            }
            else {
                // This looked like 9.999999...e^xx
                // so it will become 10e^xx
                range.location = 0;
                range.length = 1;
                if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
                CFStringDelete(string, range);
                CFStringInsert(string, 0, CFSTR("10"));
            }
        }
    }
    else {
        index = range.location-2;
        count = -1;
        do {
            character = PSCFStringGetCharacterAtIndex(string, index--);
            count++;
        } while((character=='0'||character=='.') && index > 0);
        if(count>3) {
            CFRange periodRange = CFStringFind(string, CFSTR("."), 0);
            if(periodRange.location == kCFNotFound  || periodRange.location <=index) {
                index++;
                range.location = index+1;
                range.length = count+1;
                if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
                CFStringDelete(string, range);
            }
            else {
                range.length = range.location - periodRange.location;
                range.location = periodRange.location;
                if(range.length+range.location>CFStringGetLength(string)) return CFRetain(numericString);
                CFStringDelete(string, range);
            }
        }
    }
    
    double roundedValue = CFStringGetDoubleValue(string);
    if(PSCompareDoubleValues(value, roundedValue)==kPSCompareEqualTo) {
        CFStringFindAndReplace (string,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(string)),0);
        return string;
    }
    CFRelease(string);
    
    CFMutableStringRef mutResult = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(numericString), numericString);
    CFStringFindAndReplace (mutResult,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(mutResult)),0);
    return mutResult;
}


CFStringRef PSFloatComplexCreateStringValue(float complex value)
{
    if(value==0.0) return CFSTR("0");
    
    CFStringRef realString = PSDoubleCreateStringValue(crealf(value));
    CFStringRef imagString = PSDoubleCreateStringValue(cimagf(value));

    CFMutableStringRef imagStringI = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(imagString)+2, imagString);
    CFStringAppend(imagStringI, CFSTR("•I"));
    CFRelease(imagString);
    
    if(cimagf(value)==0.0) {
        CFRelease(imagStringI);
        return realString;
    }
    
    if(crealf(value)==0.0) {
        CFRelease(realString);
        return imagStringI;
    }
    
    CFMutableStringRef combined = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, realString);
    if(cimag(value)>0) CFStringAppend(combined, CFSTR("+"));
    CFStringAppend(combined, imagStringI);
    CFRelease(realString);
    CFRelease(imagStringI);
    return combined;
}

CFStringRef PSFloatComplexCreateStringValueWithFormat(float complex value, CFStringRef format)
{
    if(value==0.0) return CFSTR("0");
    if(format == NULL) format = CFSTR("%.7g");
    
    CFStringRef realStringRough = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,crealf(value));
    CFStringRef imagStringRough = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,cimagf(value));
    
    CFStringRef realString = PSCFStringCreateStringWithRoundedNumber(realStringRough);
    CFStringRef imagString = PSCFStringCreateStringWithRoundedNumber(imagStringRough);
    
    CFRelease(realStringRough);
    CFRelease(imagStringRough);
    
    CFMutableStringRef imagStringI = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(imagString)+2, imagString);
    CFStringAppend(imagStringI, CFSTR("•I"));
    CFRelease(imagString);
    
    if(cimagf(value)==0.0) {
        CFRelease(imagStringI);
        return realString;
    }
    
    if(crealf(value)==0.0) {
        CFRelease(realString);
        return imagStringI;
    }
    
    CFMutableStringRef combined = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, realString);
    if(cimag(value)>0) CFStringAppend(combined, CFSTR("+"));
    CFStringAppend(combined, imagStringI);
    CFRelease(realString);
    CFRelease(imagStringI);
    return combined;
}

CFStringRef PSDoubleComplexCreateStringValueWithFormat(double complex value,CFStringRef format)
{
    if(value==0.0) return CFSTR("0");
    
    if(format == NULL) format = CFSTR("%.16lg");
    
    CFStringRef realStringRough = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,creal(value));
    CFStringRef imagStringRough = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,cimag(value));
    
    CFStringRef realString = PSCFStringCreateStringWithRoundedNumber(realStringRough);
    CFStringRef imagString = PSCFStringCreateStringWithRoundedNumber(imagStringRough);
    
    CFRelease(realStringRough);
    CFRelease(imagStringRough);
    
    CFMutableStringRef imagStringI = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(imagString)+2, imagString);
    CFStringAppend(imagStringI, CFSTR("•I"));
    CFRelease(imagString);
    
    if(cimag(value)==0.0) {
        CFRelease(imagStringI);
        return realString;
    }
    
    if(creal(value)==0.0) {
        CFRelease(realString);
        return imagStringI;
    }
    
    CFMutableStringRef combined = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, realString);
    if(cimag(value)>0) CFStringAppend(combined, CFSTR("+"));
    CFStringAppend(combined, imagStringI);
    CFRelease(realString);
    CFRelease(imagStringI);
    return combined;
}

CFStringRef PSDoubleComplexCreateStringValue(double complex value)
{
    if(value==0.0) return CFSTR("0");
    
    CFStringRef realString = PSDoubleCreateStringValue(creal(value));
    CFStringRef imagString = PSDoubleCreateStringValue(cimag(value));

    CFMutableStringRef imagStringI = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(imagString)+2, imagString);
    CFStringAppend(imagStringI, CFSTR("•I"));
    CFRelease(imagString);
    
    if(cimag(value)==0.0) {
        CFRelease(imagStringI);
        return realString;
    }
    
    if(creal(value)==0.0) {
        CFRelease(realString);
        return imagStringI;
    }
    
    CFMutableStringRef combined = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, realString);
    if(cimag(value)>0) CFStringAppend(combined, CFSTR("+"));
    CFStringAppend(combined, imagStringI);
    CFRelease(realString);
    CFRelease(imagStringI);
    return combined;
}

CFStringRef PSDoubleCreateStringValue(double value)
{
    if(value==0.0) return CFSTR("0");
    
    // This is a weird trick and not sure if it's the best solution to an impossible problem.
    // We need to turn float point representations into strings that are the true number.
    // No one wants to see 0.600000000085 when the answer is supposed to be 0.6
    // The approach taken here is to determine the string for a range of conversion of formats
    // starting at %.16lg, %.15lg, %.14lg,  %.13lg,  %.12lg,  %.11lg, ...
    // and look for the string where the string length dramatically drops.
    // that is, look for the highest conversion format that turns 0.600000000085 into 0.6.
    //
    // If we don't see a big drop in string length then %.16lg should be fine.
    // When we do see a big drop in string length, then reconvert the shorter string
    // back into a number and calculate the relative error.  If the relative error
    // is less than 1e-13 then accept the new string.  Otherwise return the string
    // obtained with %.16lg.
    
    
    CFStringRef format = CFSTR("%.16lg");
    CFIndex highest = 16;
    CFIndex lowest = 4;
    CFStringRef string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,value);
    CFIndex lastlength = CFStringGetLength(string);
    CFRelease(string);
    
    for(CFIndex index=highest;index>lowest;index--) {
        format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Q.%ldlg"),index);
        CFMutableStringRef copy = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, format);
        CFRelease(format);
        CFStringReplace(copy, CFRangeMake(0, 1), CFSTR("%"));
        string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, copy,value);
        CFIndex lengthDifference = lastlength - CFStringGetLength(string);
        lastlength = CFStringGetLength(string);
        double newValue = CFStringGetDoubleValue(string);
        double error = fabs(newValue - value)/value;

        if(lengthDifference>lowest&&error<1.e-13) {
            CFRelease(copy);
//            printf("possible relative error of %lg\n",error);
            
            CFMutableStringRef result = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
            CFRelease(string);
            CFStringFindAndReplace (result,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(result)),0);

            return result;
        }
        CFRelease(string);
        CFRelease(copy);
    }
    CFStringRef temp = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.16lg"),value);
    CFMutableStringRef result = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    CFStringFindAndReplace (result,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(result)),0);
    
    return result;
}


CFStringRef PSFloatCreateStringValue(float value)
{
    if(value==0.0) return CFSTR("0");
    
    CFStringRef format = CFSTR("%.7g");
    CFIndex highest = 7;
    CFIndex lowest = 4;
    CFStringRef string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, format,value);
    CFIndex lastlength = CFStringGetLength(string);
    CFRelease(string);
    
    for(CFIndex index=highest;index>lowest;index--) {
        format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Q.%ldg"),index);
        CFMutableStringRef copy = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, format);
        CFRelease(format);
        CFStringReplace(copy, CFRangeMake(0, 1), CFSTR("%"));
        string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, copy,value);
        CFIndex lengthDifference = lastlength - CFStringGetLength(string);
        lastlength = CFStringGetLength(string);
        float newValue = CFStringGetDoubleValue(string);
        float error = fabs(newValue - value)/value;
        if(lengthDifference>lowest&&error<1.e-5) {
            CFRelease(copy);
            
            CFMutableStringRef result = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
            CFRelease(string);
            CFStringFindAndReplace (result,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(result)),0);

            return result;
        }
        CFRelease(string);
        CFRelease(copy);
    }
    
    CFStringRef temp = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%.7g"),value);
    CFMutableStringRef result = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);
    CFRelease(temp);
    CFStringFindAndReplace (result,CFSTR("e"), CFSTR("E"),CFRangeMake(0,CFStringGetLength(result)),0);

    return result;
}



bool PSCFStringEqual(CFStringRef input1, CFStringRef input2)
{
    if(input1==NULL  && input2 !=NULL) return false;
    if(input1!=NULL  && input2 ==NULL) return false;
    if(input1 && input2) {
        if(CFStringCompare(input1, input2, 0) != kCFCompareEqualTo) {
            return false;
        }
    }
    return true;
}
