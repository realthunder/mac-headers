#!/bin/bash

set -e

platroot=/Applications/Xcode.app/Contents/Developer/Platforms

macsdk=${platroot}/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk
macinc=${macsdk}/usr/include
maclib=${macsdk}/System/Library/Frameworks

iossdk=${platroot}/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.0.sdk
iosinc=${iossdk}/usr/include
ioslib=${iossdk}/System/Library/Frameworks

xnu=xnu-2050.18.24
cctools=cctools-829
configd=configd-453.18
libc=Libc-825.25
launchd=launchd-442.26.2 
libutil=libutil-30

src=xnu cctools configd libc launchd libutil
apple="$PWD/dl"
mkdir -p "${apple}"

for f in $src; do
    if [ ! -d "${apple}"/$f ]; then
        curl http://opensource.apple.com/tarballs/${f##-*}/$f.tar.gz -o "${apple}"/$f.tar.gz
        tar xf "${apple}"/$f.tar.gz -C ${apple}
    fi
done

mkdir -p usr
rm -rf usr/include
cp -a "${macinc}" usr/include 
cd usr/include 
ln -s . System 

cp -af "${iosinc}"/* . 
cp -af "${apple}"/$xnu/osfmk/* . 
cp -af "${apple}"/$xnu/bsd/* . 
cp -af "${apple}"/$cctools/include/mach . 
cp -af "${apple}"/$cctools/include/mach-o . 
cp -af "${iosinc}"/mach-o/dyld.h mach-o 
cp -af "${macinc}"/mach/machine mach 
cp -af "${macinc}"/mach/machine.h mach 
cp -af "${macinc}"/machine . 
cp -af "${iosinc}"/machine . 
cp -af "${iosinc}"/sys/cdefs.h sys 
cp -af "${macinc}"/sys/dtrace.h sys 
cp -af "${maclib}"/Kernel.framework/Headers/machine/disklabel.h machine 
cp -af "${apple}"/$configd/dnsinfo/dnsinfo.h . 
cp -a "${apple}"/$libc/include/kvm.h . 
cp -a "${apple}"/$launchd/launchd/src/*.h . 
cp -a "${apple}"/$libutil/libutil.h .
cp -a i386/disklabel.h arm 
cp -a mach/i386/machine_types.defs mach/arm 

find . \( -name '*.c' -o -name '*.s' \) -exec rm -f {} \; 
mkdir -p Kernel 
cp -a "${apple}"/$xnu/libsa/libsa Kernel
