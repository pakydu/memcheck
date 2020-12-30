Thsi project is from: https://www.linkdata.se/sourcecode/memwatch/
I just want to share it on this web side.
# memcheck
A memory leak detection tool. Basically, you add a header file to your souce code files, and compile with MEMWATCH defined or not. The header file MEMWATCH.H contains detailed instructions. This is a list of some of the features present in version 2.71:
– ANSI C
– Logging to file or user function using TRACE() macro
– Fault tolerant, can repair it’s own data structures
– Detects double-frees and erroneous free’s
– Detects unfreed memory
– Detects overflow and underflow to memory buffers
– Can set maximum allowed memory to allocate, to stress-test app
– ASSERT(expr) and VERIFY(expr) macros
– Can detect wild pointer writes
– Support for OS specific address validation to avoid GP’s (segmentation faults)
– Collects allocation statistics on application, module or line level
– Rudimentary support for threads (see FAQ for details)
– Rudimentary support for C++ (disabled by default, use with care!)
