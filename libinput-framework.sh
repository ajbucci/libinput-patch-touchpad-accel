#!/bin/bash
build_dir=~/.build
if [ -d $build_dir ] 
then
    echo "Skip, build directory exists." 
else
    echo "Create build directory."
    mkdir $build_dir
fi

cd $build_dir
libinput_dir="${build_dir}/libinput"
bool_install="true"
# clone libinput
if [ -d $libinput_dir ] 
then
    echo "Pull, libinput already cloned."
    cd $libinput_dir
    pull_output=$(git pull)
    if [[ "$pull_output" == "Already up to date." ]]
    then
        echo "Already up to date. Skip build and install."
        bool_install="true" # We install anyway because we're using a pacman hook and want to overwrite the install
    fi
else
    echo "Clone libinput."
    git clone https://gitlab.freedesktop.org/libinput/libinput.git
fi

if [[ $bool_install == "true" ]]
then
    cd $libinput_dir
    # modify libinput
    regex=$(<~/libinput_modify/libinput_function_regex)
    replacement=$(<~/libinput_modify/libinput_function_edited)
    file="${libinput_dir}/src/filter-touchpad.c"
    perl -0 -i -pe "s/${regex////\\/}/${replacement////\\/}/gim" "$file"

    # build modified libinput
    sudo rm -r builddir
    meson --prefix=/usr -Ddocumentation=false -Dtests=false -Ddebug-gui=false builddir/
    ninja -C builddir/
    sudo ninja -C builddir/ install
fi
