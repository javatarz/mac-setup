defaults write com.bjango.istatmenus.status "NSStatusItem Preferred Position com.bjango.istatmenus.battery" 239.0
defaults write com.bjango.istatmenus.status "NSStatusItem Preferred Position com.bjango.istatmenus.combined" 360.5
defaults write com.bjango.istatmenus.status "NSStatusItem Preferred Position com.bjango.istatmenus.time" 145.5
defaults write com.bjango.istatmenus.status "NSStatusItem Preferred Position com.bjango.istatmenus.weather" 480.5

killall "iStat Menus Status"

defaults write com.bjango.istatmenus6.extras Time_MenubarFormat --array '{format=((EE," ",d,"__DAY_SUFFIX__"," ",MMM,", ",yyyy," [",HH,":",mm,"]"));}'