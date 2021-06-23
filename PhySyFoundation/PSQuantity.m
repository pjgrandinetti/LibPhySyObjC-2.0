//
//  PSQuantity.c
//
//  Created by PhySy Ltd on 12/9/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//
 
#import "PhySyFoundation.h"

@implementation PSQuantity

PSUnitRef PSQuantityGetUnit(PSQuantityRef quantity)
{	
    PSQuantityRef theQuantity = (PSQuantityRef) quantity;
	return theQuantity->unit;
}

void PSQuantitySetUnit(PSMutableQuantityRef quantity, PSUnitRef unit)
{
    IF_NO_OBJECT_EXISTS_RETURN(quantity,);
    IF_NO_OBJECT_EXISTS_RETURN(unit,);
    PSMutableQuantityRef theQuantity = (PSMutableQuantityRef) quantity;
    theQuantity->unit = unit;
}

PSDimensionalityRef PSQuantityGetUnitDimensionality(PSQuantityRef quantity)
{	
    IF_NO_OBJECT_EXISTS_RETURN(quantity,NULL);
    PSQuantityRef theQuantity = (PSQuantityRef) quantity;
	return PSUnitGetDimensionality(theQuantity->unit);	
}

numberType PSQuantityGetElementType(PSQuantityRef quantity)
{	
    IF_NO_OBJECT_EXISTS_RETURN(quantity,kPSNumberFloat32Type);
    PSQuantityRef theQuantity = (PSQuantityRef) quantity;
	return theQuantity->elementType;
}

bool PSQuantityHasElementType(PSQuantityRef quantity, numberType elementType)
{
    IF_NO_OBJECT_EXISTS_RETURN(quantity,NULL);
    PSQuantityRef theQuantity = (PSQuantityRef) quantity;
    if(elementType != theQuantity->elementType) return false;
    return true;
}

bool PSQuantityIsComplexType(PSQuantityRef theQuantity)
{
    if(NULL==theQuantity) return false;
    if(theQuantity->elementType==kPSNumberFloat32ComplexType || theQuantity->elementType==kPSNumberFloat64ComplexType) return true;
    return false;
}

int PSQuantityElementSize(PSQuantityRef quantity)
{
    IF_NO_OBJECT_EXISTS_RETURN(quantity,kCFNotFound);
    PSQuantityRef theQuantity = (PSQuantityRef) quantity;
    return PSNumberTypeElementSize(theQuantity->elementType);
}

bool PSQuantityHasDimensionality(PSQuantityRef quantity, PSDimensionalityRef theDimensionality)
{
    IF_NO_OBJECT_EXISTS_RETURN(quantity,false);
    PSQuantityRef quantity1 = (PSQuantityRef) quantity;

    return PSDimensionalityEqual(PSUnitGetDimensionality(quantity1->unit), theDimensionality);
//    return PSDimensionalityHasSameReducedDimensionality(PSUnitGetDimensionality(quantity1->unit), theDimensionality);
}

bool PSQuantityHasSameReducedDimensionality(PSQuantityRef input1, PSQuantityRef input2)
{
    if(input1==NULL || input2 == NULL) return false;
    PSQuantityRef quantity1 = (PSQuantityRef) input1;
    PSQuantityRef quantity2 = (PSQuantityRef) input2;
    
    return PSDimensionalityHasSameReducedDimensionality(PSQuantityGetUnitDimensionality(quantity1), PSQuantityGetUnitDimensionality(quantity2));
}

bool PSQuantityHasSameDimensionality(PSQuantityRef input1, PSQuantityRef input2)
{
    if(input1==NULL || input2 == NULL) return false;
    PSQuantityRef quantity1 = (PSQuantityRef) input1;
    PSQuantityRef quantity2 = (PSQuantityRef) input2;
    
    return PSDimensionalityEqual(PSQuantityGetUnitDimensionality(quantity1), PSQuantityGetUnitDimensionality(quantity2));
}

numberType PSQuantityBestElementType(PSQuantityRef input1, PSQuantityRef input2)
{
    PSQuantityRef quantity1 = (PSQuantityRef) input1;
    PSQuantityRef quantity2 = (PSQuantityRef) input2;
    switch (quantity1->elementType) {
        case kPSNumberFloat32Type: {
            switch (quantity2->elementType) {
                case kPSNumberFloat32Type:
                    return kPSNumberFloat32Type;
                case kPSNumberFloat64Type:
                    return kPSNumberFloat64Type;
                case kPSNumberFloat32ComplexType:
                    return kPSNumberFloat32ComplexType;
                case kPSNumberFloat64ComplexType:
                    return kPSNumberFloat64ComplexType;
            }
        }
        case kPSNumberFloat64Type: {
            switch (quantity2->elementType) {
                case kPSNumberFloat32Type:
                    return kPSNumberFloat64Type;
                case kPSNumberFloat64Type:
                    return kPSNumberFloat64Type;
                    return kPSNumberFloat64ComplexType;
                case kPSNumberFloat32ComplexType:
                    return kPSNumberFloat64ComplexType;
                case kPSNumberFloat64ComplexType:
                    return kPSNumberFloat64ComplexType;
            }
        }
        case kPSNumberFloat32ComplexType: {
            switch (quantity2->elementType) {
                case kPSNumberFloat32Type:
                    return kPSNumberFloat32ComplexType;
                case kPSNumberFloat64Type:
                    return kPSNumberFloat64ComplexType;
                case kPSNumberFloat32ComplexType:
                    return kPSNumberFloat32ComplexType;
                case kPSNumberFloat64ComplexType:
                    return kPSNumberFloat64ComplexType;
            }
        }
        case kPSNumberFloat64ComplexType:
            return kPSNumberFloat64ComplexType;
    }
}

numberType PSQuantityBestComplexElementType(PSQuantityRef input1, PSQuantityRef input2)
{
    numberType type = PSQuantityBestElementType( input1,  input2);

    switch (type) {
        case kPSNumberFloat32Type:
            return kPSNumberFloat32ComplexType;
        case kPSNumberFloat64Type:
            return kPSNumberFloat64ComplexType;
        case kPSNumberFloat32ComplexType:
            return kPSNumberFloat32ComplexType;
        case kPSNumberFloat64ComplexType:
            return kPSNumberFloat64ComplexType;
    }
}

numberType PSQuantityLargerElementType(PSQuantityRef input1, PSQuantityRef input2)
{
    PSQuantityRef quantity1 = (PSQuantityRef) input1;
    PSQuantityRef quantity2 = (PSQuantityRef) input2;
	return (quantity1->elementType > quantity2->elementType) ? quantity1->elementType: quantity2->elementType;
}

numberType PSQuantitySmallerElementType(PSQuantityRef input1, PSQuantityRef input2)
{
    PSQuantityRef quantity1 = (PSQuantityRef) input1;
    PSQuantityRef quantity2 = (PSQuantityRef) input2;
	return (quantity1->elementType < quantity2->elementType) ? quantity1->elementType: quantity2->elementType;
}

@end
