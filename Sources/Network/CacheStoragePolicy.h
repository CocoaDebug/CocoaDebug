/*
     File: CacheStoragePolicy.h
 Abstract: A function to determine the cache storage policy for a request.
  Version: 1.1
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

@import Foundation;

/*! Determines the cache storage policy for a response.
 *  \details When we provide a response up to the client we need to tell the client whether 
 *  the response is cacheable or not.  The default HTTP/HTTPS protocol has a reasonable 
 *  complex chunk of code to determine this, but we can't get at it.  Thus, we have to 
 *  reimplement it ourselves.  This is split off into a separate file to emphasise that 
 *  this is standard boilerplate that you probably don't need to look at.
 *  \param request The request that generated the response; must not be nil.
 *  \param response The response itself; must not be nil.
 *  \returns A cache storage policy to use.
 */

extern NSURLCacheStoragePolicy CacheStoragePolicyForRequestAndResponse(NSURLRequest * request, NSHTTPURLResponse * response);
