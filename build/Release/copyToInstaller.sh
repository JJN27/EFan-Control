#!/bin/sh
#set -x   # uncomment for a trace

if test "`ls FanControlDaemon 2>&1 | sed -e '/^FanControlDaemon$/d'`"  -o \
        "`ls -d 'Fan Control.prefPane' 2>&1 | sed -e '/^Fan Control\.prefPane$/d'`" -o \
        "`ls -d 'Fan Control.prefPane' 2>&1 | sed -e '/^Fan Control\.prefPane$/d'`"
then
   echo 'copyToInstaller.sh must be run from the Release directory containing the'
   echo '"FanControlDaemon", "Fan Control.prefPane" and "StartupParameters.plist" files'
   exit 1
fi

echo
/bin/echo -n 'Copying to Installer directories ... '

/bin/cp FanControlDaemon StartupParameters.plist \
        'Installer/Library/StartupItems/FanControlDaemon/'

/usr/sbin/chown -R root:wheel 'Installer/Library/StartupItems/FanControlDaemon/'
/bin/chmod 755 'Installer/Library/StartupItems/FanControlDaemon/FanControlDaemon'
/bin/chmod 644 'Installer/Library/StartupItems/FanControlDaemon/StartupParameters.plist'

/bin/rm -rf 'Installer/Library/PreferencePanes/Fan Control.prefPane'
/bin/cp -R 'Fan Control.prefPane' 'Installer/Library/PreferencePanes/'

/usr/sbin/chown -R root:wheel 'Installer/Library/PreferencePanes/Fan Control.prefPane'

echo 'completed'
