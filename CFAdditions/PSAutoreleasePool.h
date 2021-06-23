//
//  PSAutoreleasePool.h
//
//  Created by PhySy on 12/27/09.
//  Copyright (c) 2008-2014 PhySy, Ltd All rights reserved.
//

/*!
 @header PSAutoreleasePool
 
 PSAutorelease implements an autorelease pool for Core Foundation objects, 
 which employ a reference count memory management pattern.
 
 To use ...
 
 <pre><code>PSAutoreleasePoolRef thePool = PSAutoreleasePoolCreate();</code></pre>
 
... create, retain, and autorelease objects...
 
 <pre><code>PSAutoreleasePoolRelease(thePool);</code></pre>
 
 The creation and release of addition autorelease pools can be nested inside.
 
 PSAutoreleasePoolRelease should always be called in the same context (invocation 
 of a method or function, or body of a loop) in which PSAutoreleasePoolCreate was called.  
 If you release an autorelease pool that is not the top of the stack, 
 this causes all (unreleased) autorelease pools above it on the 
 stack to be released, along with all their objects.

 Core Foundation objects can be autorelease with
 CFTypeRef PSAutorelease(CFTypeRef cf)
 
 Inside your own C types you must create an autorelease method that calls
 the singleton PSAutoreleasePoolsManager method ...
 
 PSAutoreleasePoolsManagerAddObject(CFTypeRef object, void (*release)(CFTypeRef));
 
 The first argument to this method is the (object) that will be released when the 
 autorelease pool containing it is released.
 
 The second argument is the C type's' release method.
 
 This method will add the type to the most recently created PSAutoreleasePool.
 When that PSAutoreleasePool is released then all the types in its
 pool are sent a release message.   You cannot call PSAutoreleasePoolsManagerAddObject()
 until a PSAutoreleasePool has been created. 
 
 @copyright PhySy Ltd
*/

/*!
 @typedef PSAutoreleasePoolRef
 This is the type of a reference to PSAutoreleasePool.
 */
typedef struct _PSAutoreleasePool *PSAutoreleasePoolRef;

/*!
 @function PSAutoreleasePoolCreate
 @abstract Creates a new autorelease pool.
*/
PSAutoreleasePoolRef PSAutoreleasePoolCreate(void);

/*!
 @function PSAutoreleasePoolRelease
 @abstract Releases a PSAutoreleasePool object.
 @param thePool The pool to be released.
 @result YES (1) if successful, NO (0) if unsuccessful
 */
bool PSAutoreleasePoolRelease(PSAutoreleasePoolRef thePool);

/*!
 @function PSAutorelease
 @abstract Autoreleases a Core Foundation type.
 @param cf type to be autoreleased.
 @result type to be autoreleased
 @discussion Special Considerations: If cf is NULL, this will cause an error when the autorelease pool is deallocated and your application will crash.
 */
CFTypeRef PSAutorelease(CFTypeRef cf);

