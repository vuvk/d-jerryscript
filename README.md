# JerryScript in Dlang

1. CodeBlocks projects for building JerryScript in Windows in "build" folder

2. Simple JavaScript shell in "jerry_shell"

3. D-project with modules, libraries and tests in "jerry_test"

# How to build

See folder "build" and create dynamic libraries. Use implib (from BUP) for create *.lib from *.dll

    implib /S libjerry-core.lib jerry-core.dll

# What I used

Code::Blocks 17.12

mingw-w64 i636-8.1.0-release-win32-dwarf

dmd 2.080.0 + dub + bup

Coedit 3.6.14

dstep for convert *.h to *.d

# Links 

 [BUP](http://ftp.digitalmars.com/bup.zip)
 
 [DMD](https://dlang.org/download.html)

 [DUB](https://code.dlang.org/packages/dub)

 [Coedit](https://github.com/BBasile/Coedit)

 [JerryScript](https://github.com/jerryscript-project/jerryscript)

 [dstep](https://github.com/jacob-carlborg/dstep)
 