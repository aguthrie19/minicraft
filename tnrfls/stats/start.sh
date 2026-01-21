#!/usr/bin/env sh

# if this script ends, then all sub-processes end
trap 'kill $(jobs -p)' TERM EXIT

php-fpm82 -F -R -y /stats/tfm/fpm_tfm_pool.conf &
ttyd -p 7681 -b /stats -W sh &

# if either sub-process fails, then this script ends
wait -n
