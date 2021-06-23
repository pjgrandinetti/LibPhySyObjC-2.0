//
//  PSCFString.h
//
//  Created by PhySy Ltd on 2/17/12.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PSCFString
 PSCFString extends CFString with additional methods.
  

 @copyright PhySy Ltd
 */

/*!
 @function PSCFStringShow
 @abstract Prints a CFString to stderr.
 @param string the string.
 */
void PSCFStringShow(CFStringRef string);

/*!
 @function CreateCString
 @abstract create a C string from a CFString.
 @param string the CFString .
 */
char *CreateCString(CFStringRef string);

bool characterIsUpperCaseLetter(UniChar character);
bool characterIsLowerCaseLetter(UniChar character);
bool characterIsDigitOrDecimalPoint(UniChar character);
bool characterIsDigitOrDecimalPointOrSpace(UniChar character);
bool characterIsDigitOrDecimalPointOrMinus(UniChar character);

CFComparisonResult PSStringCompareStringLengths (const void *val1, const void *val2, void *context);

bool PSCFStringTrimMatchingQuotes(CFMutableStringRef theString);
bool PSCFStringTrimMatchingParentheses(CFMutableStringRef theString);
bool PSCFStringIsEnclosedInParentheses(CFStringRef theString);
UniChar PSCFStringGetCharacterAtIndex(CFStringRef theString, CFIndex index);
CFMutableStringRef PSCFMutableStringCreateWithCString(CFAllocatorRef alloc, const char *cStr, CFIndex maxLength, CFStringEncoding encoding);

long unsigned PSCFStringGetLongUnsignedInt(CFStringRef theString, bool *success);

float complex PSCFStringGetFloatComplexFromCommaSeparatedParts(CFStringRef theString);

double complex PSCFStringGetDoubleComplexFromCommaSeparatedParts(CFStringRef theString);

/*!
 @function PSCFStringGetFloatComplexValue
 @abstract Returns the primary float complex value represented by a string.
 @param string A string that represents a double value. The only allowed characters are the digit characters '0123456789', the plus sign '+', the minus sign '-', the period character '.', the characters 'e', and '*I'.
 @result The float complex value represented by string, or nan(NULL) if there is a scanning error (if the string contains disallowed characters or does not represent a double complex value).
 @discussion Consider the following example:
 
 double val = PSCFStringGetFloatComplexValue(CFSTR("0.123 + 0.456*I"));
 The variable val in this example would contain the complex value 0.123 + 0.456*I after the function is called.
 */
float complex PSCFStringGetFloatComplexValue(CFStringRef string);

/*!
 @function PSCFStringGetDoubleComplexValue
 @abstract Returns the primary double complex value represented by a string.
 @param string A string that represents a double value. The only allowed characters are the digit characters '0123456789', the plus sign '+', the minus sign '-', the period character '.', the characters 'e', and '*I'.
 @result The double complex value represented by string, or nan(NULL) if there is a scanning error (if the string contains disallowed characters or does not represent a double complex value).
 @discussion Consider the following example:
 
 double val = PSCFStringGetDoubleComplexValue(CFSTR("0.123 + 0.456*I"));
 The variable val in this example would contain the complex value 0.123 + 0.456*I after the function is called.
 */
double complex PSCFStringGetDoubleComplexValue(CFStringRef string);

/*!
 @function PSFloatComplexCreateStringValueWithFormat
 @abstract Creates a string representation of a float complex value.
 @param value complex number.
 @param format C printf format.
 @result string representation of complex number.
 */
CFStringRef PSFloatComplexCreateStringValueWithFormat(float complex value,CFStringRef format);

/*!
 @function PSDoubleComplexCreateStringValueWithFormat
 @abstract Creates a string representation of a double complex value.
 @param value complex number.
 @param format C printf format.
@result string representation of complex number.
 */
CFStringRef PSDoubleComplexCreateStringValueWithFormat(double complex value,CFStringRef format);

CFStringRef PSFloatCreateStringValue(float value);
CFStringRef PSDoubleCreateStringValue(double value);

/*!
 @function PSComplexFromCString
 @abstract Calculates and Returns the double complex value represented by the complex arithmetic expression in the string.
 @param string A string that contains a complex arithmetic expression
 @result The double complex value represented by string, or nan(NULL) if there is a scanning error (if the string contains disallowed characters or does not represent a double complex value).
 @discussion Consider the following example:
 
 <pre><code>double val = PSComplexFromCString("0.123 + 0.456*I");</code></pre>
 The variable val in this example would contain the complex value 0.123 + 0.456*I after the function is called.
 
 <pre><code>double val = PSComplexFromCString("(0.123 + 0.456*I)/(1.32+4.5*I)");</code></pre>
 The variable val in this example would contain the complex value 0.100688+0.00220167*I after the function is called.
 */
double complex PSComplexFromCString(const char *string);

bool PSCFStringEqual(CFStringRef input1, CFStringRef input2);
