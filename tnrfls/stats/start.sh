#!/usr/bin/env sh

# if this script ends, then all sub-processes end
trap 'kill $(jobs -p)' TERM EXIT

php-fpm -F -y /tfm/fpm_tfm_pool.conf &
ttyd -p auth:7681 sh &

# if either sub-process fails, then this script ends
wait -n