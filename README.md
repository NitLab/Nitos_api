NITOS API
===============
NITOS API DESCRIPTION
___________________________

NITOS API is an XMLRPC API that exposes all the information of NITOS Scheduler database.
The stored information in the NITOS Scheduler database is:
  - The users (apparently these are the joomla users of NITOS web interface)
  - The slices
  - The resources – both nodes and channels
  - The reservation information for the nodes and for the channels
  - Table responsible for association between users and slices

We have implemented 4 categories of methods that can be called from an XML RPC client. 
GET methods, ADD methods, DELETE methods and UPDATE methods. When a client makes a method call, he should follow 
this generic structure “Auth,filter,retValue” for the GET methods and 
this “Auth,filter”, for the other categories. Auth is for authentication purposes, filter is for filtering the request 
and is a struct, retValue is for specifying which particular value to return and is an array.
