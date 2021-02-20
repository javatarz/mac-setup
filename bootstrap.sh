zip_file=~/Downloads/mac-setup.zip
extract_dir=~/Downloads/mac-setup

set +x
set -e

curl -o $zip_file -Li https://github.com/javatarz/mac-setup/archive/main.zip
unzip mac-setup.zip -d $extract_dir

cd $extract_dir/mac-setup-main
sh install.sh

rm -rf $extract_dir $zip_file
