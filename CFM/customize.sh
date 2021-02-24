print_modname() {
  ui_print "*********************************************"
  ui_print "---------------Magisk Module:_CFM-------------------"
  ui_print "####God give me strength! ! !💪💪💪####"
  ui_print "*********************************************"
}
#安装
on_install() {
  ui_print "- 正在释放文件"
  unzip -o "$ZIPFILE" 'system/*' -d "$MODPATH" >&2
  #unzip -o "$ZIPFILE" 'ramdisk/*' -d "$MODPATH" >&2
  #extract  "$ZIPFILE" 'system' "$MODPATH" 
  ui_print $MODPATH
}
#设置权限
set_permissions() {
    ui_print "- 正在设置权限"
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  
  set_perm_recursive  $MODPATH  0  0  0755  0644
  set_perm  $MODPATH/clash_service.sh  0  0  0777  0644
  set_perm  $MODPATH/clash_tproxy.sh  0  0  0777  0644
  set_perm  $MODPATH/post-fs-data.sh  0  0  0777  0644
  set_perm  $MODPATH/service.sh  0  0  0777  0644
  set_perm  $MODPATH/uninstall.sh  0  0  0777  0644

  set_perm  $MODPATH/system/bin/clash  0  0  0777  0644
  set_perm  $MODPATH/system/bin/clash_control  0  0  0777  0644

  set_perm  $MODPATH/system/bin/curl  0  0  0777  0644
  set_perm  $MODPATH/system/bin/termux-shell  0  0  0777  0644
  set_perm  $MODPATH/system/bin/mod_config  0  0  0777  0644
  set_perm  $MODPATH/system/bin/modconfig  0  0  0777  0644
  set_perm  $MODPATH/system/bin/upgeoip  0  0  0777  0644

  set_perm  $MODPATH/system/etc/00AA_Linux_App/script/cron.hourly  0  0  0777  0644
  set_perm  $MODPATH/system/etc/00AA_Linux_App/script/cron.hourly/0Log_Clear  0  0  0777  0644
  
  #设置权限，基本不要去动
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.

print_modname
on_install
set_permissions