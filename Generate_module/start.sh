#!/bin/sh

#脚本描述:
#1.生成Magisk模块
#2.生成模块路径>>主文件目录>OUT_MODULE>xxx.zip
#

#获取当前脚本运行绝对路径
WORK_HOME=$(dirname $(readlink -f $0))
#获取主目录路径
APP_HOME=$(cd $(dirname $(readlink -f $0))/..; pwd)
#Magisk模块文件目录
MAGISK_HOME=${APP_HOME}/Magisk_File

TMPDIR=${APP_HOME}/OUT_MODULE/tmp

#Magisk最新安装脚本地址
module_installer_link='https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh'
#Geoip地址
geoip_download_link='https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb'
#Clash核心地址
clash_releases_link='https://github.com/Dreamacro/clash/releases'
#架构
architecture=('armv7' 'armv8' '386' 'amd64')

mk_zipdirtree(){
mkdir -p ${APP_HOME}/OUT_MODULE/tmp/download
printf '创建模块结构...\n'
for ARCH in ${architecture[@]}
do
    printf '创建适用于 "%s" 的结构...\n' ${ARCH}
    #mkdir -p ${APP_HOME}/OUT_MODULE/tmp/download/${ARCH}
    mkdir -p ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/META-INF/com/google/android
    mkdir -p ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/system/bin
done

#mkdir -p ${APP_HOME}/OUT_MODULE/tmp/scripts

}




core_file(){

#wget url -P <aimPath> -O fileName
#curl -L url -o <filePath>

printf '下载Magisk模块安装脚本...\n'
curl -L ${module_installer_link} -o ${APP_HOME}/OUT_MODULE/tmp/update-binary
printf '下载Geoip文件 ...\n'
curl -L ${geoip_download_link} -o ${APP_HOME}/OUT_MODULE/tmp/Country.mmdb
for ARCH in ${architecture[@]}
do
    printf '下载Clash "%s" 核心 ...\n' ${ARCH}
    curl -L ${clash_releases_link}/latest -o ${TMPDIR}/version
    required_version=$(cat ${TMPDIR}/version | grep -o "v[0-9]\.[0-9]\.[0-9]" | sort -u)
    printf '下载地址 "%s"  ...\n' ${clash_releases_link}/download/${required_version}/clash-linux-${ARCH}-${required_version}.gz
    curl -L ${clash_releases_link}/download/${required_version}/clash-linux-${ARCH}-${required_version}.gz -o ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/system/bin/clash.gz
    gzip -d ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/system/bin/clash.gz
    
done
printf '生成 "update-script" \n'
echo '#MAGISK' >>  ${APP_HOME}/OUT_MODULE/tmp/update-script



printf '复制文件到文件夹... \n'
for ARCH in ${architecture[@]}
do
    printf '复制文件到 "%s" 文件夹 ...\n' ${ARCH}
    cp ${APP_HOME}/OUT_MODULE/tmp/update-binary ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/META-INF/com/google/android
    cp ${APP_HOME}/OUT_MODULE/tmp/update-script ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/META-INF/com/google/android
    cp ${MAGISK_HOME}/module.prop ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    cp ${APP_HOME}/OUT_MODULE/tmp/Country.mmdb ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    cp ${MAGISK_HOME}/clash_control.sh ${APP_HOME}/OUT_MODULE/tmp/${ARCH}/system/bin/clash_control
    cp ${MAGISK_HOME}/clash_service.sh ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    cp ${MAGISK_HOME}/clash_tproxy.sh ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    cp ${MAGISK_HOME}/service.sh ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    cp ${MAGISK_HOME}/uninstall.sh ${APP_HOME}/OUT_MODULE/tmp/${ARCH}

done

}


create_zip(){
for ARCH in ${architecture[@]}
do
    printf '打包模块 "%s"  ...\n' ${ARCH}
    cd ${APP_HOME}/OUT_MODULE/tmp/${ARCH}
    zip -r ${APP_HOME}/OUT_MODULE/cfm_${ARCH}.zip ./*

done

}

start_gen(){

if [ ! -d ${APP_HOME}/OUT_MODULE ];
then
    mk_zipdirtree
elif [ -d ${APP_HOME}/OUT_MODULE/tmp ];
then
    rm -rf ${APP_HOME}/OUT_MODULE/tmp
    mk_zipdirtree
else
    mk_zipdirtree
fi

core_file
create_zip
}


echo "-----开始生成模块-----"
start_gen


exit 0




