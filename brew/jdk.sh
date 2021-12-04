#!/bin/sh

brew list | grep openjdk@8 >/dev/null

if test $? -eq 0; then
  echo ">>> Setting up symlink for JDK8"
  sudo rm -f /Library/Java/JavaVirtualMachines/openjdk-8.jdk
  sudo ln -sfn /usr/local/opt/openjdk@8/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-8.jdk

  jenv add /Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home/
fi

brew list | grep openjdk@11 >/dev/null

if test $? -eq 0; then
  echo ">>> Setting up symlink for JDK11"
  sudo rm -f /Library/Java/JavaVirtualMachines/openjdk-11.jdk
  sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

  jenv add /Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home/
fi

