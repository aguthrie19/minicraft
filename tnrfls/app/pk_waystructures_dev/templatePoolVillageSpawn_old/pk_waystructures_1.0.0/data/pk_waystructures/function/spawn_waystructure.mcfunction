# Find the marker, place the block, and run KawaMood's placement script
execute as @e[type=marker,tag=ws_spawn_trigger] at @s run function pk_waystones:cmd/setblock/waystone {waystone:{variant:"tuff"}}



# Kill the trigger marker after it finishes
kill @e[type=marker,tag=ws_spawn_trigger]