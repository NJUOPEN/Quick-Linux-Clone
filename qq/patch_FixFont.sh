(
cat <<EOF

REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes]
"MS Shell Dlg"="Droid Sans Fallback"
"SimSun"="Droid Sans Fallback"
"Tahoma"="WenQuDroid Sans FallbackanYi"

EOF
) > tempreg.tmp

env WINEPREFIX=$HOME/.longene/qq/ regedit tempreg.tmp
rm tempreg.tmp

read -n 1 -p 补丁安装完成，按任意键退出
echo

