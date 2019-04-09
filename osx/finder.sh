user_name=`whoami`
echo ">> Setting ~/$user_name as the finder home"
defaults write com.apple.finder NewWindowTarget "PfHm"
defaults write com.apple.finder NewWindowTargetPath "file:///Users/$user_name/"

killall Finder
