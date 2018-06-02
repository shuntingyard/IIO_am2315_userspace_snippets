#! /bin/bash

# TODO
#
# - Add case control flow for setup | teardown.
# - Remove hardwired stuff, get more generic.
# - enriched comments
#

MOD="am2315"

sudo -v -p "[sudo] please let me have your password: "

# load
sudo modprobe -v $MOD

# create new i2c device on proper bus
sudo su -c "echo -n $MOD 0x5c > /sys/bus/i2c/devices/i2c-1/new_device"

# trigger setup
sudo modprobe -v iio-trig-hrtimer
sudo mkdir -p "/sys/kernel/config/iio/triggers/hrtimer/$MOD-ht"
sudo su -c "echo -n 3000 > /sys/devices/trigger0/sampling_frequency"

# associate trigger with iio device
sudo su -c "echo -n $MOD-ht > /sys/bus/iio/devices/iio:device0/trigger/current_trigger"

# buffer setup
CHANNEL_DIR="/sys/bus/iio/devices/iio:device0/scan_elements"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_humidityrelative_en"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_temp_en"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_timestamp_en"
sudo su -c "echo -n 1 > /sys/bus/iio/devices/iio:device0/buffer/enable"
