# CMAKE-BUILDSCRIPT
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Description
bash script to create, configure, debug, install, test, and run cmake based cpp projects quickly.

---
## Usage
just copy the code below to a file named *run* in your project's root directory.
### the run file code:
```sh
#!/bin/bash

if [[ -e cmake-buildscript/run.sh ]] ; then
  exec cmake-buildscript/run.sh $@
else
  git clone https://github.com/ImranSangle/cmake-buildscript && exec cmake-buildscript/run.sh $@
fi
```
After that execute:

`./run init`

and your cmake based cpp project is ready.

## How it works

It will first clone this repo in the project's root directory and execute it,
then the script will ask you for some information required for building the project.

Once the project is created, you can use `./run` to run the project, or use other commands like:

- `./run build`
- `./run compile`
- `./run debug`
- `./run install`
- `./run test`
- `./run reconfigure`
- `./run clean`

Use `./run help` or see [List of commands](#List-of-commands) for more information.

## Info
1. You don't need to use any of the file in the cloned *cmake-buildscript* folder, this is because, if you want to get the latest version of this script, you just need to either `git pull` in the *cmake-buildscript* directory
or just delete the *cmake-buildscript* directory and run the `./run` it will get the latest build from this repo.

2. In the first run it will create a *runconfig* file in the same directory for storing project variables.

## Note
1. Never edit/delete the *runconfig* file manually, it is generated for use by run script only.
2. the run file must be only executed in the same directory where the file itself is stored.

## List of commands.
- **init:** initialize a cmake based project with boilerplate code and directories.
- **build:** build the cmake project.
- **compile:** build and compile all the executables and libraries.
- **test:** build compile and test the project with ctest.
- **install:** build compile and install the project if cmake install() command is defined in CMakeLists.txt.
- **debug:** build compile and debug the project with gdb as debugger.
- **run:** build compile and run the current project.
- **reconfigure:** reconfigure the variables in runconfig file
- **clean:** remove the build directory.
