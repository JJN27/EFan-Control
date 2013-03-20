#!/bin/sh
#set -x   # uncomment for a trace

if test "`ls FanControlDaemon 2>&1 | sed -e '/^FanControlDaemon$/d'`"  -o \
        "`ls -d 'Fan Control.prefPane' 2>&1 | sed -e '/^Fan Control\.prefPane$/d'`" -o \
        "`ls -d 'Fan Control.prefPane' 2>&1 | sed -e '/^Fan Control\.prefPane$/d'`"
then
   echo 'installFanControl.sh must be run from the Release directory containing the'
   echo '"FanControlDaemon", "Fan Control.prefPane" and "StartupParameters.plist" files'
   exit 1
fi

echo
/bin/echo -n 'Stopping FanControlDaemon ... '
/usr/bin/killall FanControlDaemon 2>&1 >/dev/null
echo 'completed'
sleep 1

/bin/cp FanControlDaemon '/Library/StartupItems/FanControlDaemon'
/bin/cp StartupParameters.plist '/Library/StartupItems/StartupParameters.plist'

/usr/sbin/chown root:wheel '/Library/StartupItems/FanControlDaemon/FanControlDaemon' \
                           '/Library/StartupItems/StartupParameters.plist'
/bin/chmod 755 '/Library/StartupItems/FanControlDaemon/FanControlDaemon'
/bin/chmod 644 '/Library/StartupItems/FanControlDaemon/StartupParameters.plist'

/bin/rm -rf '/Library/PreferencePanes/Fan Control.prefPane'
/bin/cp -R 'Fan Control.prefPane' '/Library/PreferencePanes'

/usr/sbin/chown -R root:wheel '/Library/PreferencePanes/Fan Control.prefPane'

echo
echo 'Installed:'
/bin/ls -l '/Library/StartupItems/FanControlDaemon/FanControlDaemon'
/bin/ls -ld '/Library/PreferencePanes/Fan Control.prefPane'

echo
/bin/echo -n '(Re)Starting FanControlDaemon ... '
sleep 1
/Library/StartupItems/FanControlDaemon/FanControlDaemon start
echo 'completed'
