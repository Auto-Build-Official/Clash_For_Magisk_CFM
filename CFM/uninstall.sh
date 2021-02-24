#!/system/bin/sh

#clash_data_dir="/sdcard/Documents/clash"
linux_root='/data/00AA_Linux_App'
#linux_home='/sdcard/Linux_App'

remove_data_dir() {
  #rm -rf ${clash_data_dir}
  rm -rf ${linux_root}
  #rm -rf ${linux_home}
  #挂载系统可写
  mount -o remount,rw /
  #将位于/data的定时器目录链接到根目录(/var)
  rm -rf /var
  #恢复系统只读
  mount -o remount,ro /
}

remove_data_dir