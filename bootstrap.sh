zip_file=~/Downloads/mac-setup.zip
extract_dir=~/Downloads/mac-setup
branch=apple-silicon

set -x
set -e

echo ">> Download latest code from $branch to $zip_file"
curl -o $zip_file -Li https://github.com/javatarz/mac-setup/archive/$branch.zip

echo ">> Extract $zip_file to $extract_dir"
set +e
unzip $zip_file -d $extract_dir
set -e

echo ">> Open $extract_dir/mac-setup-$branch"
cd "$extract_dir/mac-setup-$branch"
echo ">> Run install"
sh install.sh

echo ">> Remove $extract_dir and $zip_file"
rm -rf $extract_dir $zip_file
