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


linux下的测试工具真是少之又少，还不好用，最近试用了memwatch，感觉网上的介绍不太好，所以放在这里跟大家分享 。其实大部分都是看的帮助，很多地方翻译得不好还有错，请原谅指出最好看原文。如果转载或引用，请注明我的博客地址，谢谢。
       
1 介绍
MemWatch由 Johan  Lindh 编写，是一个开放源代码 C 语言内存错误检测工具。MemWatch支持 ANSI C，它提供结果日志纪录，能检测双重释放（double-free）、错误释放（erroneous free）、内存泄漏（unfreed memory）、溢出(Overflow)、下溢(Underflow)等等。
 
1.1 MemWatch的内存处理
MemWatch将所有分配的内存用0xFE填充，所以，如果你看到错误的数据是用0xFE填充的，那就是你没有初始化数据。例外是calloc()，它会直接把分配的内存用0填充。
MemWatch将所有已释放的内存用0xFD填充(zapped with 0xFD).如果你发现你使用的数据是用0xFD填充的，那你就使用的是已释放的内存。在这种情况，注意MemWatch会立即把一个"释放了的块信息"填在释放了的数据前。这个块包括关于内存在哪儿释放的信息，以可读的文本形式存放，格式为"FBI<counter>filename(line)"。如:"FBI<267>test.c(12)".使用FBI会降低free()的速度，所以默认是关闭的。使用mwFreeBufferInfo(1)开启。
为了帮助跟踪野指针的写情况，MemWatch能提供no-mans-land（NML）内存填充。no-mans-land将使用0xFC填充.当no-mans-land开启时，MemWatch转变释放的内存为NML填充状态。
 
1.2初始化和结束处理
一般来说，在程序中使用MemWatch的功能，需要手动添加mwInit()进行初始化，并用对应的mwTerm ()进行结束处理。
当然，如果没有手动调用mwInit()，MemWatch能自动初始化.如果是这种情形，memwatch会使用atext()注册mwTerm()用于atexit-queue. 对于使用自动初始化技术有一个告诫;如果你手动调用atexit()以进行清理工作，memwatch可能在你的程序结束前就终止。为了安全起见，请显式使用mwInit()和mwTerm().
涉及的函数主要有：
mwInit()    mwTerm()    mwAbort()
 
1.3 MemWatch的I/O 操作
对于一般的操作，MemWatch创建memwatch.log文件。有时，该文件不能被创建;MemWatch会试图创建memwatNN.log文件，NN在01~99之间。
如果你不能使用日志，或者不想使用，也没有问题。只要使用类型为"void func(int c)"的参数调用mwSetOutFunc()，然后所有的输出都会按字节定向到该函数.
当ASSERT或者VERIFY失败时，MemWatch也有Abort/Retry/Ignore处理机制。默认的处理机制没有I/O操作，但是会自动中断程序。你可以使用任何其他Abort/Retry/Ignore的处理机制,只要以参数"void func(int c)"调用mwSetAriFunc()。后面在1.2使用一节会详细讲解。
涉及的函数主要有：
mwTrace()           mwPuts()        mwSetOutFunc()  mwSetAriFunc()
mwSetAriAction()    mwAriHandler()  mwBreakOut()
 
1.4 MemWatch对C++的支持
    可以将MemWatch用于C++,但是不推荐这么做。请详细阅读memwatch.h中关于对C++的支持。
 
2 使用
2.1 为自己的程序提供MemWatch功能
*  在要使用MemWatch的.c文件中包含头文件"memwatch.h"
*  使用GCC编译（注意：不是链接）自己的程序时，加入-DMEMWATCH -DMW_STDIO
如：gcc -DMEMWATCH -DMW_STDIO –o test.o –c  test1.c
 
2.2 使用MemWatch提供的功能
1）在程序中常用的MemWatch功能有：
*  mwTRACE ( const char* format_string, ... );
或TRACE ( const char* format_string, ... );
*  mwASSERT ( int, const char*, const char*, int )
或ASSERT ( int, const char*, const char*, int )
*  mwVERIFY ( int, const char*, const char*, int )
或VERIFY ( int, const char*, const char*, int )
*  mwPuts ( const char* text )
*  ARI机制（ mwSetAriFunc(int (*func)(const char *))，
          mwSetAriAction(int action)，
          mwAriHandler ( const char* cause )）
*  mwSetOutFunc (void (*func)(int))
*  mwIsReadAddr(const void *p, unsigned len )
*  mwIsSafeAddr(void *p, unsigned len )
*  mwStatistics ( int level )
*  mwBreakOut ( const char* cause)
 
2）mwTRACE，mwASSERT，mwVERIFY和mwPuts顾名思义，就不再赘述。仅需要注意的是，Memwatch定义了宏TRACE,    ASSERT 和 VERIFY.如果你已使用同名的宏,memwatch2.61及更高版本的memwatch不会覆盖你的定义。MemWatch2.61及以后，定义了mwTRACE, mwASSERT 和 mwVERIFY宏，这样，你就能确定使用的是memwatch的宏定义。2.61版本前的memwatch会覆盖已存在的同名的TRACE, ASSERT 和 VERIFY定义。
当然，如果你不想使用MemWatch的这几个宏定义，可以定义MW_NOTRACE, MW_NOASSERT 和 MW_NOVERIFY宏，这样MemWatch的宏定义就不起作用了。所有版本的memwatch都遵照这个规则。
3）ARI机制即程序设置的“Abort, Retry, Ignore选择陷阱。
mwSetAriFunc：
设置“Abort, Retry, Ignore”发生时的MemWatch调用的函数.当这样设置调用的函数地址时，实际的错误消息不会打印出来，但会作为一个参数进行传递。
如果参数传递NULL，ARI处理函数会被再次关闭。当ARI处理函数关闭后， meewatch会自动调用有mwSetAriAction()指定的操作。
正常情况下，失败的ASSERT() or VERIFY()会中断你的程序。但这可以通过mwSetAriFunc()改变，即通过将函数"int myAriFunc(const char *)"传给它实现。你的程序必须询问用户是否中断，重试或者忽略这个陷阱。返回2用于Abort， 1用于Retry，或者0对于Ignore。注意retry时，会导致表达式重新求值.
 MemWatch有个默认的ARI处理器。默认是关闭的，但你能通过调用mwDefaultAri()开启。注意这仍然会中止你的程序除非你定义MEMWATCH_STDIO允许MemWatch使用标准C的I/O流。
同时，设置ARI函数也会导致MemWatch不将ARI的错误信息写向标准错误输出，错误字符串而是作为'const char *'参数传递到ARI函数.
mwSetAriAction：
如果没有ARI处理器被指定，设置默认的ARI返回值。默认是MW_ARI_ABORT
mwAriHandler：
这是个标准的ARI处理器，如果你喜欢就尽管用。它将错误输出到标准错误输出，并从标准输入获得输入。
mwSetOutFunc：
将输出转向调用者给出的函数(参数即函数地址)。参数为NULL，表示把输出写入日志文件memwatch.log.
mwIsReadAddr:
检查内存是否有读取的权限
mwIsSafeAddr:
检查内存是否有读、写的权限
mwStatistics:
设置状态搜集器的行为。对应的参数采用宏定义。
#define MW_STAT_GLOBAL  0       /* 仅搜集全局状态信息 */
#define MW_STAT_MODULE  1       /* 搜集模块级的状态信息 */
#define MW_STAT_LINE    2       /* 搜集代码行级的状态信息 */
#define MW_STAT_DEFAULT 0       /* 默认状态设置 */
mwBreakOut:
当某些情况MemWatch觉得中断(break into)编译器更好时，就调用这个函数.如果你喜欢使用MemWatch,那么可以在这个函数上设置执行断点。
其他功能的使用，请参考源代码的说明。

memwatch的使用（二）：[url]http://brantc.blog.51cto.com/410705/118221[/url]
