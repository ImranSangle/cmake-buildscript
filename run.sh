#!/bin/bash

 # Copyright (C) 2025 ImranSangle
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <https://www.gnu.org/licenses/>.

#------------------function definitions------------------------

help(){
  local macro="(auto builds and compiles)."
  echo "Available Commands:"
  echo "init         Create a new cmake based project."
  echo "build        Build the cmake project."
  echo "compile      Compile all the executables and libraries."
  echo "test         Test the project with ctest $macro"
  echo "install      Install the project if cmake install command is used $macro"
  echo "debug        Debug the project with gdb debugger (if installed) $macro"
  echo "run          Build,compile and run the project."
  echo "reconfigure  Reconfigure cmake and run variables used for building the project."
  echo "clean        Remove the cmake build directory where all the files reside."
}

create_cmakelist(){
  echo -e "\ncmake_minimum_required(VERSION ${CMAKE_MIN_VERSION})\n\nproject(${PROJECT})\n\nadd_executable(${EXENAME} src/${EXENAME}.cpp)" > CMakeLists.txt
}

create_main(){
  echo -e "\nint main(int argc,char* argv[]){\n\nreturn 0;\n\n}" > src/main.cpp
}

init(){
  if [[ ! -e "./src" ]] ; then
     mkdir src
     create_main
  fi
  if [[ ! -e "./include" ]] ; then
     mkdir include
  fi
  if [[ ! -e "./test" ]] ; then
     mkdir test
  fi
  if [[ ! -e "./CMakeLists.txt" ]] ; then
     create_cmakelist 
  fi
  echo "cmake based project directory structure created!"
}

build(){
  if [[ $DEBUG == "true" ]]; then
    echo "Making debug build."
    cmake -S . -B build -G "Unix Makefiles" -D CMAKE_EXPORT_COMPILE_COMMANDS=1 -D CMAKE_BUILD_TYPE=Debug ${CMAKE_DEFINES}
  else
    cmake -S . -B build -G "Unix Makefiles" -D CMAKE_EXPORT_COMPILE_COMMANDS=1 -D CMAKE_BUILD_TYPE=Release ${CMAKE_DEFINES}
  fi
}

compile(){
  if [[ -n ./build ]] ; then
    build
  fi
  cd build
  make
  if [[ $TEST == "true" ]] ; then
  ctest -VV
  fi
}

test(){
  if [[ -e ./build ]] ; then
    compile
  else
    build
    compile
  fi
  ctest -VV
}

install(){
  if [[ -e ./build ]] ; then
    compile
  else
    build
    compile
  fi
  make install
}

run(){
  if [[ -e ./build ]] ; then
    compile && exec ./$EXENAME
  else
    build
    compile && exec ./$EXENAME
  fi
}

debug(){
  if [[ -e ./build ]] ; then
    compile
  else
    build
    compile
  fi
  gdb $EXENAME
}

clean(){
  if [[ -e ./build ]] ; then
    rm -r ./build
  fi
}

config(){
  if [[ -n $1 && -n $2 ]] ; then
     echo "$1=$2" >> ./runconfig
   else
    echo "incorrect argument provided!"
  fi
}

configure(){
  echo "Enter your project name (Default=$PROJECT)."
  read VALUE
  if [[ -z $VALUE ]] ; then
    config PROJECT $PROJECT
  else
    config PROJECT $VALUE
  fi

  echo "Enter cmake minimum required version (Default=3.5)."
  read VALUE
  if [[ -z $VALUE ]] ; then
    config CMAKE_MIN_VERSION "3.5"
  else
    config CMAKE_MIN_VERSION $VALUE
  fi

  echo "Enter your executable name (Default=$EXENAME)."
  read VALUE
  if [[ -z $VALUE ]] ; then
    config EXENAME $EXENAME
  else
    config EXENAME $VALUE
  fi

  echo "Do you want to run tests after compiling? [y/N]"
  read VALUE
  if [[ $VALUE == "y" || $VALUE == "Y" ]] ; then
   config TEST true
  else
   config TEST false
  fi

  echo "Do you want to build this project as debug build? [Y/n]"
  read VALUE
  if [[ $VALUE == "n" || $VALUE == "N" ]] ; then
   config DEBUG false
  else
   config DEBUG true
  fi
  
  echo "Do you want to configure cmake defines? [y/N]"
  read VALUE
  if [[ $VALUE == "y" || $VALUE == "Y" ]] ; then
    echo "Generate New 'n' or Append 'a' or clear 'c' ?"
    read VALUE
    case $VALUE in 
      a) 
        echo "Enter Defines to append [NAME=VALUE]"
        read VALUE
        if [[ -n $VALUE ]] ; then
         config CMAKE_DEFINES "\"${CMAKE_DEFINES} -D ${VALUE}\""
        fi ;;
      n) 
        echo "Enter New defines [NAME=VALUE]"
        read VALUE
        if [[ -n $VALUE ]] ; then
         config CMAKE_DEFINES "\"-D ${VALUE}\""
        fi ;;
      c) echo "Cmake defines cleared!" ; config CMAKE_DEFINES " " ;;
      *) echo "Nothing selected, aborting." ; config CMAKE_DEFINES "\"$CMAKE_DEFINES\""
    esac 
  else
    config CMAKE_DEFINES "\"$CMAKE_DEFINES\""
  fi
}

reconfigure(){
  rm ./runconfig
  clean
  touch runconfig
  configure
  echo "new configurations:"
  cat ./runconfig
}

#----------- entry--------------

if [[ ! -e "./runconfig" && $1 != "help" ]] ; then
  echo "No configurations found! generating now.."
  touch runconfig
  configure
fi

if [[ $1 != "help" ]] ; then source ./runconfig ; fi

if [[ -n $1 ]] ; then
  $@
else
 run
fi

