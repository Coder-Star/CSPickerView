#!/bin/sh
CUR_DIR=$(cd "$(dirname "$0")"; pwd)


# 编译模式，包括Release及Debug
BUILD_MODE="Release"
# FRAMEWORK的Target名称，也是输出的Framework和Bundle名称，保持一致的目的是方便合并处理
# 设置如下：macho-type；xcode12剔除arm64架构；设置Deployment Target；
TARGET_NAME="CSPickerView"
# Framework输出路径
FRAMEWORK_PATH=${CUR_DIR}/CSPickerView/Frameworks
# 生成临时的Framework路径
BUILD_PATH=${CUR_DIR}/TempFrameworks
# 工程路径
PROJECT_PARH=${CUR_DIR}/Example/CSPickerViewSDK

# 删除冗余文件
rm -rf ${BUILD_PATH}
cd ${PROJECT_PARH}

# 构建真机和模拟器版本
xcodebuild -target "${TARGET_NAME}" -configuration ${BUILD_MODE} -arch arm64 -arch armv7 -arch armv7s ONLY_ACTIVE_ARCH=NO defines_module=yes -sdk iphoneos BUILD_DIR="${BUILD_PATH}" BUILD_ROOT="${BUILD_PATH}" clean build
xcodebuild -target "${TARGET_NAME}" -configuration ${BUILD_MODE} -arch x86_64 -arch i386 ONLY_ACTIVE_ARCH=NO defines_module=yes -sdk iphonesimulator BUILD_DIR="${BUILD_PATH}" BUILD_ROOT="${BUILD_PATH}" clean build

# 将框架结构复制到目标输出文件夹,删除之前的framework
rm -rf "${FRAMEWORK_PATH}/${TARGET_NAME}.framework"
cp -R "${BUILD_PATH}/${BUILD_MODE}-iphoneos/${TARGET_NAME}.framework" "${FRAMEWORK_PATH}"

# 使用lipo创建通用二进制文件，
lipo -create -output "${FRAMEWORK_PATH}/${TARGET_NAME}.framework/${TARGET_NAME}" "${BUILD_PATH}/${BUILD_MODE}-iphonesimulator/${TARGET_NAME}.framework/${TARGET_NAME}" "${BUILD_PATH}/${BUILD_MODE}-iphoneos/${TARGET_NAME}.framework/${TARGET_NAME}"

# 拷贝swiftmodule文件
simulator_modules_path="${BUILD_PATH}/${BUILD_MODE}-iphonesimulator/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule/."
# 如果.swiftmodule文件夹存在,就复制到项目目录
if [ -d "${simulator_modules_path}" ]; then
cp -R "${simulator_modules_path}" "${FRAMEWORK_PATH}/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule"
fi


# Bundle处理，如果没有资源，可注释掉该部分代码
# 资源路径
RESOURE_PATH=${CUR_DIR}/CSPickerView/Assets
if [ -e "${RESOURE_PATH}" ]
then
cp -R ${RESOURE_PATH} "${FRAMEWORK_PATH}/${TARGET_NAME}.bundle"
fi

# xcode10.2之后，需要将真机与模拟器生成的Swift.h文件进行合并

FAT_SWIFT_HEADER_PATH="${FRAMEWORK_PATH}/${TARGET_NAME}.framework/Headers/${TARGET_NAME}-Swift.h"

# 替换方式，如果模拟器与真机对外提供的API一致，则选择该方式，优先选择该方式，可减小文件体积
FAT_SWIFT_HEADER_ARCHITECTURE="#if defined(__x86_64__) \&\& __x86_64__ || (__i386__) \&\& __i386__ || (__arm64__) \&\& __arm64__ || (__armv7__) \&\& __armv7__ || (__armv7s__) \&\& __armv7s__"
sed -i "" "1d" ${FAT_SWIFT_HEADER_PATH}
sed -i "" "1d" ${FAT_SWIFT_HEADER_PATH}
sed -i "" "1s/^/${FAT_SWIFT_HEADER_ARCHITECTURE}/" ${FAT_SWIFT_HEADER_PATH}


# 合并方式，如果模拟器与真机对外提供的API不一致，则选择该方式
#SIMULATOR_SWIFT_HEADER_PATH="${BUILD_PATH}/${BUILD_MODE}-iphonesimulator/${TARGET_NAME}.framework/Headers/${TARGET_NAME}-Swift.h"
#DEVICE_SWIFT_HEADER_PATH="${BUILD_PATH}/${BUILD_MODE}-iphoneos/${TARGET_NAME}.framework/Headers/${TARGET_NAME}-Swift.h"
#if [ -e "${SIMULATOR_SWIFT_HEADER_PATH}" ] && [ -e "${DEVICE_SWIFT_HEADER_PATH}" ]
#then
#echo "#if TARGET_OS_SIMULATOR" > "${FAT_SWIFT_HEADER_PATH}"
#cat "${SIMULATOR_SWIFT_HEADER_PATH}" >> "${FAT_SWIFT_HEADER_PATH}"
#echo "#else" >> ${FAT_SWIFT_HEADER_PATH}
#cat "${DEVICE_SWIFT_HEADER_PATH}" >> "${FAT_SWIFT_HEADER_PATH}"
#echo "#endif" >> "${FAT_SWIFT_HEADER_PATH}"
#fi

# 删除生成过程中产生的冗余文件
rm -rf ${PROJECT_PARH}/build/
rm -rf ${BUILD_PATH}
rm -rf "${FRAMEWORK_PATH}/${TARGET_NAME}.framework/_CodeSignature"
rm -rf "${FRAMEWORK_PATH}/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule/Project"

# 打开 目标输出文件夹
#open "${FRAMEWORK_PATH}"

