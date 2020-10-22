#!/bin/bash
#
# Custom build script for Eureka kernels by Chatur27 and Gabriel260 @Github -2020
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Set default directories
ROOT_DIR=$(pwd)
# OUT_DIR=$ROOT_DIR/out
KERNEL_DIR=$ROOT_DIR
DTB_DIR=./arch/arm64/boot/dts/exynos
DTBO_DIR=./arch/arm64/boot/dts/exynos/dtbo

# Set custom kernel variables
PROJECT_NAME="Eureka Kernel"
CORES=$(nproc --all)
REV=1.0
ZIPNAME=Eureka_Rx.x_Axxx_xxxx_x.zip
DEFAULT_NAME=Eureka_Rx.x_Axxx_P/Q/R

# Export commands
export KBUILD_BUILD_USER=Chatur
export KBUILD_BUILD_HOST=Eureka.org
export VERSION=$DEFAULT_NAME
export ARCH=arm64
export CROSS_COMPILE=$(pwd)/toolchain/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=$(pwd)/toolchain/bin/arm-linux-gnueabi-

# Get date
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")

####################### Devices List #########################

SM_A105X="Samsung Galaxy A10"
DEFCONFIG_A105P=a10_defconfig
DEVICE_A105P=A105

DEFCONFIG_A105Q=a10_00_defconfig
DEVICE_A105Q=A105

SM_A205X="Samsung Galaxy A20"
DEFCONFIG_A205=exynos7885-a20_defconfig
DEVICE_A205=A205

SM_A305X="Samsung Galaxy A30"
DEFCONFIG_A305=exynos7885-a30_defconfig
DEVICE_A305=A305

SM_A307X="Samsung Galaxy A30s"
DEFCONFIG_A307=exynos7885-a30s_defconfig
DEVICE_A307=A307

SM_A405X="Samsung Galaxy A40"
DEFCONFIG_A405=exynos7885-a40_defconfig
DEVICE_A405=A405

SM_A505X="Samsung Galaxy A50"
DEFCONFIG_A505=exynos9610-a50_defconfig
DEVICE_A505=A505

################################################################

######################## Android OS list #######################

androidp="Android 9 (Pie)"
androidq="Android 10 (Q)"
androidr="Android 11 (R)"

################################################################


################### Executable functions #######################
CLEAN_SOURCE()
{
	echo "*****************************************************"
	echo " "
	echo "              Cleaning kernel source"
	echo " "
	echo "*****************************************************"
	make clean
	CLEAN_SUCCESS=$?
	if [ $CLEAN_SUCCESS != 0 ]
		then
			echo " Error: make clean failed"
			exit
	fi

	make mrproper
	MRPROPER_SUCCESS=$?
	if [ $MRPROPER_SUCCESS != 0 ]
		then
			echo " Error: make mrproper failed"
			exit
	fi
	rm $DTB_DIR/*.dtb
	rm $DTBO_DIR/*.dtbo
	rm -rf kernel_zip/Image
	rm -rf kernel_zip/dtbo.img
	sleep 1
	echo "*****************************************************"	
}

BUILD_KERNEL()
{
	echo "*****************************************************"
	echo "           Building kernel for $DEVICE_Axxx          "
	export ANDROID_MAJOR_VERSION=$ANDROID
	export LOCALVERSION=-$VERSION
	make  $DEFCONFIG
	make -j$CORES
	sleep 1	
}

ZIPPIFY()
{
	# Make Eureka flashable zip
	
	if [ -e "arch/$ARCH/boot/Image" ]
	then
	{
		echo -e "*****************************************************"
		echo -e "             Building Eureka flashable zip           "
		echo -e "*****************************************************"
		
		# Copy Image and dtbo.img to kernel directory
		cp -f arch/$ARCH/boot/Image kernel_zip/Image
		cp -f arch/$ARCH/boot/dtbo.img kernel_zip/dtbo.img
		
		# Change into kernel directory
		cd kernel_zip
		zip -r9 $ZIPNAME META-INF modules patch ramdisk tools anykernel.sh Image dtbo.img version
		chmod 0777 $ZIPNAME
		# Change back into kernel source directory
		cd ..
		sleep 2
	}
	fi
}

PROCESSES()
{
	# Allow user to choose how many cores to be taken by compiler
	echo "Your system has $CORES cores."
	read -p "Please enter how many cores to be used by compiler (Leave blank to use all cores) : " cores;
	if [ "${cores}" == "" ]; then
		echo " "
		echo "Using all $CORES cores for compilation"
		sleep 2
	else 
		echo "Using $cores cores for compilation "
		CORES=$cores
		sleep 2
	fi
}

ENTER_VERSION()
{
	# Enter kernel revision for this build.
	read -p "Please type kernel version without R (E.g: 4.7) : " rev;
	if [ "${rev}" == "" ]; then
		echo "Using default $REV as version"
	else
		REV=$rev
		echo " "
		echo "     Version = $REV"
	fi
	sleep 2
}

RENAME()
{
	# Give proper name to kernel and zip name
	VERSION="Eureka_R"$REV"_"$DEVICE_Axxx"_"P/Q/R
	ZIPNAME="Eureka_R"$REV"_"$DEVICE_Axxx"_"xxxx"_"$ANDROID".zip"
}

DISPLAY_ELAPSED_TIME()
{
	# Find out how much time build has taken
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))

	BUILD_SUCCESS=$?
	if [ $BUILD_SUCCESS != 0 ]
		then
			echo " Error: Build failed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
			exit
	fi
	
	echo -e "                     Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
	sleep 1
}

OS_MENU()
{
	# Give the choice to choose Android Version
	PS3='
Please select your Android Version: '
	menuos=("$androidp" "$androidq" "$androidr" "Exit")
	select menuos in "${menuos[@]}"
	do
	    case $menuos in
        	"$androidp")
			echo " "
			echo "Android 9 (Pie) chosen as Android Major Version"
			ANDROID=p
			AND_VER=9
			sleep 2
			echo " "
			break
			;;
		"$androidq")
			echo " "
			echo "Android 10 (Q) chosen as Android Major Version"
			ANDROID=q
			AND_VER=10
			sleep 2
			echo " "
			break
			;;
		"$androidr")
			echo " "
			echo "Android 11 (R) chosen as Android Major Version"
			ANDROID=r
			AND_VER=11
			sleep 2
			echo " "
			break
			;;
		"Exit")
          		echo " "
          		echo "Exiting build script.."
          		sleep 2
			echo " "
          		exit
            		;;
        	*) 
        		echo Invalid option.
        		;;
		esac
	done
}


#################################################################


###################### Script starts here #######################

clear
PROCESSES
clear
ENTER_VERSION
clear
echo "******************************************************"
echo "*             $PROJECT_NAME Build Script             *"
echo "*                  Developer: Chatur                 *"
echo "*                Co-Developer: Gabriel               *"
echo "*                                                    *"
echo "*          Compiling kernel using Linaro-GCC         *"
echo "*                                                    *"
echo "* Some information about parameters set:             *"
echo -e "*  > Architecture: $ARCH                             *"
echo    "*  > Jobs: $CORES                                         *"
echo    "*  > Revision for this build: R$REV                   *"
echo    "*  > Kernel Name Template: $VERSION    *"
echo    "*  > Build user: $KBUILD_BUILD_USER                              *"
echo    "*  > Build machine: $KBUILD_BUILD_HOST                       *"
echo    "*  > Build started on: $BUILD_START                    *"
echo    "*  > ARM64 Toolchain exported                        *"
echo    "*  > ARM32 Toolchain exported                        *"
echo -e "******************************************************"
echo " "

echo "Devices avalaible for compilation: "
echo " "
PS3='
Please select your device: '
menuoptions=("$SM_A105X" "$SM_A205X" "$SM_A305X" "$SM_A307X" "$SM_A405X" "$SM_A505X" "Exit")
select menuoptions in "${menuoptions[@]}"
do
    case $menuoptions in
        "$SM_A105X")
        	echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A105Q kernel"
		DEVICE_Axxx=$DEVICE_A105Q
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A105Q
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A105P
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
        "$SM_A205X")
		echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A205 kernel"
		DEVICE_Axxx=$DEVICE_A205
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A205
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A205
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
	"$SM_A305X")
		echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A305 kernel"
		DEVICE_Axxx=$DEVICE_A305
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A305
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A305
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
	"$SM_A307X")
		echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A307 kernel"
		DEVICE_Axxx=$DEVICE_A307
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A307
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A307
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
	"$SM_A405X")
		echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A405 kernel"
		DEVICE_Axxx=$DEVICE_A405
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A405
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A405
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
	"$SM_A505X")
		echo " "
        	echo "Android versions available: "
        	echo " "
		OS_MENU
		echo " "
		CLEAN_SOURCE
		echo " "
		echo "        Starting compilation of $DEVICE_A505 kernel"
		DEVICE_Axxx=$DEVICE_A505
		if [ $AND_VER -eq 10 ]
		then
			DEFCONFIG=$DEFCONFIG_A505
		elif [ $AND_VER -eq 9 ]
		then
			DEFCONFIG=$DEFCONFIG_A505
		elif [ $AND_VER -eq 11 ]
		then
			echo " "
			echo "       Android 11 kernel is not yet released.."
			echo " "		
		fi
		RENAME
		sleep 2
		echo " "
		sleep 2		
		BUILD_KERNEL
		echo " "
		sleep 2
		ZIPPIFY
		sleep 2
		CLEAN_SOURCE
		echo " "
		DISPLAY_ELAPSED_TIME
		echo " "
		echo "                 *****************************************************"
		echo "*****************                                                     *****************"
		echo "*                      $DEVICE_Axxx kernel for Android $AND_VER build finished                      *"
		echo "*****************                                                     *****************"
		echo "                 *****************************************************"
		break
		;;
	"Exit")
            	echo " Exiting build script.."
          	sleep 2
          	exit
          	;;
        *) 
        	echo Invalid option.
        	;;
    esac
done

