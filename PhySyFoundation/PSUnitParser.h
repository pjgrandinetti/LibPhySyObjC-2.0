//
//  PSUnitParser.h
//
//  Created by PhySy Ltd on 5/3/13.
//  Copyright (c) 2012-2014 PhySy Ltd. All rights reserved.
//

#ifndef PSUnitParser_h
#define PSUnitParser_h

extern CFErrorRef unitError;

/*
 @function PSUnitForUnderivedSymbol
 @abstract Returns the unit with an underived symbol, if known.
 @param input The symbol.
 @param error a CFErrorRef.
 @result the unit or NULL if unit with symbol is not found.
 */
PSUnitRef PSUnitForParsedSymbol(CFStringRef string, double *unit_multiplier, CFErrorRef *error);

#endif
