#!/bin/bash

CONFIG_FILE_PATH="app/etc/config.php"
MODULE_PATH="app/code/"
DESIGN_PATH="app/design/frontend/"
DO_NOT_DELETE_FILE=".gitkeep"
THEME_FOLDERS=("etc" "media" "web")
WEB_FOLDERS=("css" "js" "images" "fonts")
PARENT_THEME_PATH="<parent>Magento/blank</parent>"
DEFAULT_VIEW_FILE="vendor/magento/theme-frontend-blank/etc/view.xml"
PREVIEW_FILENAME="preview.jpg"
BUILDER_OPTIONS=('theme' 'module')
DEFAULT_MODULE_VERSION="1.0.0"

ROOT_PATH=$(pwd)


isMagento2() {
    [ -f "$CONFIG_FILE_PATH" ]
}

setMagento2Path() {
    if ! isMagento2; then
        echo -e "\033[91m$ROOT_PATH is not a Magento 2 project\033[0m"
        echo -e "Please specify a \033[33mMagento 2 path\033[0m and press [ENTER]"
        read ROOT_PATH
        ROOT_PATH="$(pwd)/$ROOT_PATH"

        if [ ! -d $ROOT_PATH ]; then
            setMagento2Path
        fi

        if [ ! -d $ROOT_PATH ]; then
            setMagento2Path
        else
            cd $ROOT_PATH
        fi
    fi
}
setVendorName() {
    echo -e "Enter your \033[33mvendor_name\033[0m and press [ENTER]: "
    read VENDOR_NAME
}

setThemeName() {
    echo -e "Enter your \033[33mtheme_name\033[0m and press [ENTER]: "
    read THEME_NAME
}

setModuleName() {
    echo -e "Enter your \033[33mmodule_name\033[0m and press [ENTER]: "
    read MODULE_NAME
}

setThemeTitle() {
    echo -e "Enter your \033[33mtheme_title\033[0m and press [ENTER]: "
    read THEME_TITLE
}

createDirectory() {
    if [ -d $1 ]; then
        printf "\033[33mSkipping\033[0m %s\n" $1
    else
        mkdir -p $1
        printf "\033[32mCreated\033[0m %s\n" $1
    fi
}
createThemeFile() {
    theme_file_path="$1/theme.xml"
    if [ -f $theme_file_path ]; then
        echo -e "\033[33mUpdated\033[0m $theme_file_path"
    else
        echo -e "\033[32mCreated\033[0m $theme_file_path"
    fi
    cat > $theme_file_path <<- EOM
<!--
    /**
    * Copyright © 2015 Magento. All rights reserved.
    * See COPYING.txt for license details.
    */
-->
<theme xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:Config/etc/theme.xsd">
    <title>$THEME_TITLE</title>
    $PARENT_THEME_PATH
    <media>
        <preview_image>media/preview.jpg</preview_image>
    </media>
</theme>
EOM
}
createModuleFile() {
    module_file_path="$1/module.xml"
    NAMESPACE=${VENDOR_NAME}_${MODULE_NAME}
    if [ -f $module_file_path ]; then
        echo -e "\033[33mUpdated\033[0m $module_file_path"
    else
        echo -e "\033[32mCreated\033[0m $module_file_path"
    fi
    cat > $module_file_path <<- EOM
<?xml version="1.0"?>

<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:Module/etc/module.xsd">
    <module name="$NAMESPACE" setup_version="$DEFAULT_MODULE_VERSION">
    </module>
</config>
EOM
}
createRegistrationFile() {
    registration_file_path="$1/registration.php"
    if [ -f $registration_file_path ]; then
        echo -e "\033[33mUpdated\033[0m $registration_file_path"
    else
        echo -e "\033[32mCreated\033[0m $registration_file_path"
    fi
    cat > $registration_file_path <<- EOM
 <?php
    /**
    * Copyright © 2015 Magento. All rights reserved.
    * See COPYING.txt for license details.
    */
    \Magento\Framework\Component\ComponentRegistrar::register(
        \Magento\Framework\Component\ComponentRegistrar::THEME,
        'frontend/$VENDOR_NAME/$THEME_NAME',
        __DIR__
        );
EOM
}
createModuleRegistrationFile() {
    registration_file_path="$1/registration.php"
    NAMESPACE=${VENDOR_NAME}_${MODULE_NAME}
    if [ -f $registration_file_path ]; then
        echo -e "\033[33mUpdated\033[0m $registration_file_path"
    else
        echo -e "\033[32mCreated\033[0m $registration_file_path"
    fi
    cat > $registration_file_path <<- EOM
<?php

\Magento\Framework\Component\ComponentRegistrar::register(
    \Magento\Framework\Component\ComponentRegistrar::MODULE,
    '$NAMESPACE',
    __DIR__
);
EOM
}
createFakePreviewFile() {
    preview_path="$1/media/$PREVIEW_FILENAME"
    touch $preview_path
    echo -e "\033[32mCreated\033[0m $preview_path"
}
createThemeStructure() {
    # Create vendor directory
    VENDOR_PATH="$ROOT_PATH/$DESIGN_PATH$VENDOR_NAME"
    echo
    echo -e "> Generating a theme skeleton into \033[32m$VENDOR_PATH\033[0m"
    createDirectory $VENDOR_PATH

    # Create theme directory
    THEME_PATH="$VENDOR_PATH/$THEME_NAME"
    createDirectory $THEME_PATH

    # Create theme subdirectories
    for SUB_DIR in "${THEME_FOLDERS[@]}"
    do
        createDirectory "$THEME_PATH/$SUB_DIR"
    done

    # Create web subdirectories
    for SUB_DIR in "${WEB_FOLDERS[@]}"
    do
        createDirectory "$THEME_PATH/web/$SUB_DIR"
    done

    echo
    echo -e "> Generating declaration theme files into \033[32m$THEME_PATH\033[0m"
    # Create theme.xml file
    createThemeFile $THEME_PATH

    # Create registration.php
    createRegistrationFile $THEME_PATH

    # Copy view.xml
    cp $DEFAULT_VIEW_FILE "$THEME_PATH/etc/"

    # Create fake preview.jpg
    createFakePreviewFile $THEME_PATH
}
createModuleStructure() {
    # Create vendor directory
    VENDOR_PATH="$ROOT_PATH/$MODULE_PATH$VENDOR_NAME"
    echo
    echo -e "> Generating a module skeleton into \033[32m$VENDOR_PATH\033[0m"
    createDirectory $VENDOR_PATH

    # Create module directory
    MODULE_PATH="$VENDOR_PATH/$MODULE_NAME"
    createDirectory $MODULE_PATH

    # Create etc directory
    ETC_PATH="$MODULE_PATH/etc"
    createDirectory "$ETC_PATH"


    echo
    echo -e "> Generating declaration module files into \033[32m$ETC_PATH\033[0m"
    # Create module.xml file
    createModuleFile $ETC_PATH

    # Create registration.php
    createModuleRegistrationFile $MODULE_PATH

    eval "$ROOT_PATH/bin/magento setup:upgrade"
    exit
}
buildTheme() {
    # Prompt
    setMagento2Path
    setVendorName
    setThemeName
    setThemeTitle

    # Execute
    createThemeStructure
    printf "Don't forget to replace the \033[33mpreview.jpg\033[0m in \033[33m%s\033[0m\n" "$THEME_PATH/web/media"
}

buildModule() {
    # Prompt
    setMagento2Path
    setVendorName
    setModuleName
    setModuleVersion

    # Execute
    createModuleStructure
}
echo
echo "Magento 2 Builder (1.0.1)"
echo "======================="
echo
echo "This command helps you generate Magento2 theme or module skeleton"
echo
echo -e "What would you like to build ?"
PS3="Please, select you option and press [ENTER]: "
select option in "${BUILDER_OPTIONS[@]}"
do
    case $option in
        "theme")
            echo
            echo "You have selected Magento 2 $option Buidler"
            echo
            buildTheme
            ;;
        "module")
            echo "You have selected Magento 2 $option Buidler"
            echo
            buildModule
            ;;
        *) ;;
    esac
    break
done
exit
echo
