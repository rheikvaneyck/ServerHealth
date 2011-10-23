#!/bin/bash

# Das script cron-server-health kommt nach /etc/cron.daily/

[ -f cron-server-health ] || cp cron-server-health /etc/cron.daily

[ -x /etc/cron.daily/cron-server-health ] || chmod a+x /etc/cron.daily/cron-server-health

# Das script server-health.sh kommt nach /usr/sbin/

[ -f check-health.sh ] || cp check-health.sh /usr/sbin

# Fall das script nicht ausführbar ist, exe bit setzen

[ -x /usr/sbin/check-health.sh ] || chmod a+x /usr/sbin/check-health.sh

# Die logs werden nach /var/log/health geschrieben, das Verzeichnis müsstest Du anlegen, wenn es das noch nicht gibt.

[ -d /var/log/health ] || mkdir /var/log/health
