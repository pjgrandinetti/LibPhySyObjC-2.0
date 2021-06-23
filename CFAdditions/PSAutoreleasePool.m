//
//  PSAutoreleasePool.c
//
//  Created by PhySy Ltd on 12/27/09.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

#import "PhySyFoundation.h"
#import "PSAutoreleasePool.h"

#ifndef FREE
#define FREE(X) {free(X); X=NULL;}
#endif

#ifndef IF_SELF_DOESNT_EXISTS_RETURN
#define IF_SELF_DOESNT_EXISTS_RETURN(X) if(NULL==theUnit) {fprintf(stderr, "*** WARNING - %s %s - object doesn't exist.\n",__FILE__,__func__); return X;}
#endif

#ifndef IF_NO_OBJECT_EXISTS_RETURN
#define IF_NO_OBJECT_EXISTS_RETURN(OBJECT,X) if(OBJECT==NULL) {fprintf(stderr, "*** WARNING - %s %s - object doesn't exist.\n",__FILE__,__func__); return X;}
#endif

#define POOL_NOT_FOUND -1
#define POOLOBJECT_NOT_FOUND -1

struct _PSAutoreleasePoolObject {
    CFAllocatorRef allocator;
	CFTypeRef object;
	void (*release)(CFTypeRef);
};

typedef struct _PSAutoreleasePoolObject * PSAutoreleasePoolObjectRef;

struct _PSAutoreleasePool
{ 
    CFAllocatorRef allocator;
	PSAutoreleasePoolObjectRef *pool_objects;
	int number_of_pool_objects;
};

struct _PSAutoreleasePoolsManager
{
	PSAutoreleasePoolRef *pools;
	int number_of_pools;
};

typedef struct _PSAutoreleasePoolsManager *PSAutoreleasePoolsManagerRef;

// PSAutoreleasePoolsManager is a Singleton
static PSAutoreleasePoolsManagerRef autorelease_pool_manager = NULL;


/**************************************************************************
 PSAutoreleasePoolObject methods
 *************************************************************************/

/*
 @function PSAutoreleasePoolObjectCreate
 Creates a PSAutoreleasePoolObject.
 @param allocator The Core Foundation allocator to use to allocate the memory. Pass NULL or kCFAllocatorDefault to use the current default allocator.
 @param object The object wrapped into PSAutoreleasePoolObject.
 @param (*release)(CFTypeRef) release method for object.
 */
static PSAutoreleasePoolObjectRef PSAutoreleasePoolObjectCreate(CFAllocatorRef allocator, CFTypeRef object, void (*release)(CFTypeRef))
{
    PSAutoreleasePoolObjectRef thePoolObject  = CFAllocatorAllocate(allocator,sizeof(struct _PSAutoreleasePoolObject),0);
    
	IF_NO_OBJECT_EXISTS_RETURN(thePoolObject,NULL)
    
	thePoolObject->allocator = allocator;
	thePoolObject->object = object;
	thePoolObject->release = release;
	return thePoolObject;
}

/*
 @function PSAutoreleasePoolObjectDeallocate
 Deallocates a PSAutoreleasePoolObject.
 @param thePoolObject PSAutoreleasePoolObject to be deallocated.
 @result YES (1) if successful, NO (0) if unsuccessful
 */
static bool PSAutoreleasePoolObjectDeallocate(PSAutoreleasePoolObjectRef thePoolObject)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePoolObject,false)
	
    if(thePoolObject) {
        CFAllocatorDeallocate(thePoolObject->allocator,thePoolObject);
        thePoolObject=NULL;
    }
	return true;
}

/*
 @function PSAutoreleasePoolObjectGetReleaseFunction
 Returns the release function for object wrapped in PSAutoreleasePoolObject.
 @param thePoolObject PSAutoreleasePoolObject with object to be released.
 @result release function
 */
static void *PSAutoreleasePoolObjectGetReleaseFunction(PSAutoreleasePoolObjectRef thePoolObject)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePoolObject,NULL)
	
	return thePoolObject->release;
}

/*
 @function PSAutoreleasePoolObjectGetObject
 Returns the release function for object wrapped in PSAutoreleasePoolObject.
 @param thePoolObject PSAutoreleasePoolObject with object to be released.
 @result release function
 */
static CFTypeRef PSAutoreleasePoolObjectGetObject(PSAutoreleasePoolObjectRef thePoolObject)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePoolObject,NULL)
	
	return thePoolObject->object;
}



/**************************************************************************
 PSAutoreleasePoolsManager methods
 *************************************************************************/
static bool PSAutoreleasePoolDeallocate(PSAutoreleasePoolRef thePool);
static bool PSAutoreleasePoolAddObject(PSAutoreleasePoolRef thePool, CFTypeRef object, void (*release)(CFTypeRef));


static PSAutoreleasePoolsManagerRef PSAutoreleasePoolsManagerCreate(void)
{
    PSAutoreleasePoolsManagerRef thePoolsManager  = CFAllocatorAllocate(kCFAllocatorDefault,sizeof(struct _PSAutoreleasePoolsManager),0);
	IF_NO_OBJECT_EXISTS_RETURN(thePoolsManager,NULL)
    
	thePoolsManager->pools = NULL;
	thePoolsManager->number_of_pools = 0;
	return thePoolsManager;
}

static int PSAutoreleasePoolsManagerIndexOfPool(PSAutoreleasePoolRef thePool)
{
    IF_NO_OBJECT_EXISTS_RETURN(autorelease_pool_manager,POOL_NOT_FOUND)
	IF_NO_OBJECT_EXISTS_RETURN(thePool,POOL_NOT_FOUND)
    
	int poolIndex = POOL_NOT_FOUND;
	for(int i=0;i<autorelease_pool_manager->number_of_pools;i++) {
		if(autorelease_pool_manager->pools[i] == thePool) {
			poolIndex = i;
			break;
		}
	}
	return poolIndex;
}

/*
 @function PSAutoreleasePoolsManagerRemovePool
 @param thePool The pool to be removed.
 @result YES (1) if successful, NO (0) if unsuccessful
 */
static bool PSAutoreleasePoolsManagerRemovePool(PSAutoreleasePoolRef thePool)
{
	IF_NO_OBJECT_EXISTS_RETURN(autorelease_pool_manager,false)
	IF_NO_OBJECT_EXISTS_RETURN(thePool,false)
    
	int poolIndex =  PSAutoreleasePoolsManagerIndexOfPool(thePool);
	if(poolIndex == POOL_NOT_FOUND) return false;
    
	// deallocate pool at poolIndex along with all pools with higher indexes
	for(int i=autorelease_pool_manager->number_of_pools-1;i>=poolIndex;i--)
		PSAutoreleasePoolDeallocate(autorelease_pool_manager->pools[i]);
    
	autorelease_pool_manager->number_of_pools = poolIndex;
    
    if(autorelease_pool_manager->number_of_pools>0) {
        realloc(autorelease_pool_manager->pools,autorelease_pool_manager->number_of_pools*sizeof(CFTypeRef));
        return true;
    }
    return false;
}

static bool PSAutoreleasePoolsManagerDeallocate(PSAutoreleasePoolsManagerRef thePoolsManager)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePoolsManager,false)
    
	for(int i=0;i<thePoolsManager->number_of_pools;i++) PSAutoreleasePoolsManagerRemovePool(thePoolsManager->pools[i]);
    
    if(thePoolsManager->pools) {
        CFAllocatorDeallocate(CFGetAllocator(thePoolsManager),thePoolsManager->pools);
        thePoolsManager->pools=NULL;
    }
    
    if(thePoolsManager) {
        CFAllocatorDeallocate(CFGetAllocator(thePoolsManager),thePoolsManager);
        thePoolsManager=NULL;
    }
	return true;
}


/*
 @function PSAutoreleasePoolsManagerGetNumberOfPools
 @result number of autorelease pools
 */
static int PSAutoreleasePoolsManagerGetNumberOfPools(void)
{
    if(autorelease_pool_manager==NULL) return 0;
    
	return autorelease_pool_manager->number_of_pools;
}

/*
 @function PSAutoreleasePoolsManagerAddPool
 Adds the pool to the manager.
 @param thePool The pool to be added.
 */
static void PSAutoreleasePoolsManagerAddPool(PSAutoreleasePoolRef thePool)
{
	IF_NO_OBJECT_EXISTS_RETURN(thePool,)
	
    if(autorelease_pool_manager==NULL) autorelease_pool_manager = PSAutoreleasePoolsManagerCreate();
    if(autorelease_pool_manager) {
        autorelease_pool_manager->number_of_pools++;
        autorelease_pool_manager->pools = CFAllocatorReallocate(kCFAllocatorDefault,
                                                                autorelease_pool_manager->pools,
                                                                autorelease_pool_manager->number_of_pools*sizeof(CFTypeRef),
                                                                0);
        autorelease_pool_manager->pools[autorelease_pool_manager->number_of_pools-1] = thePool;
    }
	return;
}

/*
 @function PSAutoreleasePoolsManagerAddObject
 Adds the object to the most recently created PSAutoreleasePool.
 @param object The object to be released.
 @param release The method that releases the object.
 */
static bool PSAutoreleasePoolsManagerAddObject(CFTypeRef object, void (*release)(CFTypeRef))
{
	IF_NO_OBJECT_EXISTS_RETURN(autorelease_pool_manager,false)
	IF_NO_OBJECT_EXISTS_RETURN(object,false)
	IF_NO_OBJECT_EXISTS_RETURN(release,false)
    
	// add object to PSAutoreleasePool at the top of the list
	
	if(autorelease_pool_manager->pools) {
		PSAutoreleasePoolAddObject(autorelease_pool_manager->pools[autorelease_pool_manager->number_of_pools-1],object,release);
		return true;
	}
	//      pool exists
    
	fprintf(stderr,"*** ERROR - %s %s - No PSAutoreleasePool exists.\n",__FILE__,__func__);
	return false;
}


/**************************************************************************
 PSAutoreleasePool methods
 *************************************************************************/


PSAutoreleasePoolRef PSAutoreleasePoolCreate()
{
    PSAutoreleasePoolRef thePool = CFAllocatorAllocate(kCFAllocatorDefault,sizeof(struct _PSAutoreleasePool),0);
	
	IF_NO_OBJECT_EXISTS_RETURN(thePool,NULL)
	
    thePool->allocator = kCFAllocatorDefault;
	thePool->pool_objects = NULL;
	thePool->number_of_pool_objects = 0;
	PSAutoreleasePoolsManagerAddPool(thePool);
	return thePool;
}

/*
 @function PSAutoreleasePoolDeallocate
 @abstract Deallocates a PSAutoreleasePool object.
 @param thePool The pool to be deallocated.
 @result YES (1) if successful, NO (0) if unsuccessful
 */
static bool PSAutoreleasePoolDeallocate(PSAutoreleasePoolRef thePool)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePool,false)
    
	for(int i=0;i<thePool->number_of_pool_objects;i++) if(thePool->pool_objects[i]) {
		PSAutoreleasePoolObjectRef pool_object = thePool->pool_objects[i];
        void (*release_function)(CFTypeRef) = PSAutoreleasePoolObjectGetReleaseFunction(pool_object);
		(*release_function)(PSAutoreleasePoolObjectGetObject(pool_object));
		PSAutoreleasePoolObjectDeallocate(pool_object);
	}
    if(thePool->pool_objects) {
        CFAllocatorDeallocate(thePool->allocator,thePool->pool_objects);
        thePool->pool_objects=NULL;
    }
    if(thePool) {
        CFAllocatorDeallocate(thePool->allocator,thePool);
        thePool=NULL;
    }
    return true;
}

bool PSAutoreleasePoolRelease(PSAutoreleasePoolRef thePool)
{	
	IF_NO_OBJECT_EXISTS_RETURN(thePool,false)
    
	return PSAutoreleasePoolsManagerRemovePool(thePool);
}

/*
 @function PSAutoreleasePoolGetNumberOfPoolObjects
 @abstract Returns the number of objects in the autorelease pool
 @param thePool The pool.
 @result number of objects in pool 
 */
static int PSAutoreleasePoolGetNumberOfPoolObjects(PSAutoreleasePoolRef thePool)
{
	IF_NO_OBJECT_EXISTS_RETURN(thePool,0)
    return thePool->number_of_pool_objects;
}

/*
 @function PSAutoreleasePoolAddObject
 @abstract Adds an object to the most recently created autorelease pool.
 @param thePool The pool where object will be added.
 @param object The object to be added.
 @param release The release function for object.
 @result YES (1) if successful, NO (0) if unsuccessful
 */
static bool PSAutoreleasePoolAddObject(PSAutoreleasePoolRef thePool, CFTypeRef object, void (*release)(CFTypeRef))
{
	IF_NO_OBJECT_EXISTS_RETURN(thePool,false)
    
	if(object) {
		PSAutoreleasePoolObjectRef pool_object = PSAutoreleasePoolObjectCreate(thePool->allocator,object,release);
		thePool->number_of_pool_objects++;
        thePool->pool_objects = CFAllocatorReallocate(thePool->allocator,
                                                      thePool->pool_objects,
                                                      thePool->number_of_pool_objects*sizeof(CFTypeRef),
                                                      0);
		thePool->pool_objects[thePool->number_of_pool_objects-1] = pool_object;
		return true;	
	}
	return false;	
}



/**************************************************************************
 Core Foundation convenience method
 *************************************************************************/


CFTypeRef PSAutorelease(CFTypeRef cf)
{
	IF_NO_OBJECT_EXISTS_RETURN(cf,NULL)

	PSAutoreleasePoolsManagerAddObject(cf, CFRelease);
	return cf;
}


