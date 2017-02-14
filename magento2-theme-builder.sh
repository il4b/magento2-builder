#!/bin/bash

CONFIG_FILE_PATH="app/etc/config.php"
DESIGN_PATH="app/design/frontend/"
DO_NOT_DELETE_FILE=".gitkeep"
THEME_FOLDERS=("etc" "media" "web")
WEB_FOLDERS=("css" "js" "images" "fonts")
PARENT_THEME_PATH="<parent>Magento/blank</parent>"
DEFAULT_VIEW_FILE="vendor/magento/theme-frontend-blank/etc/view.xml"

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
createThemeStructure() {
    # Create vendor directory
    VENDOR_PATH="$ROOT_PATH/$DESIGN_PATH$VENDOR_NAME"
    echo
    echo -e "> Generating a theme skeleton into \033[32m$DESIGN_PATH$VENDOR_NAME\033[0m"
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
    echo
}

echo
echo "Magento 2 Theme (1.0.0)"
echo "======================="
echo
echo "This command helps you generate Magento2 theme skeleton"
echo
# Prompt
setMagento2Path
setVendorName
setThemeName
setThemeTitle

# Execute
createThemeStructure
printf "Don't forget to copy your preview.jpg in %s\n" "$THEME_PATH/web/media"
