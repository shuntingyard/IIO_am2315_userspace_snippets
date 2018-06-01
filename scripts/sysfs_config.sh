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

# create nwe i2c device on proper bus
sudo su -c "echo -n $MOD 0x5c > /sys/bus/i2c/devices/i2c-1/new_device"

# trigger setup
sudo modprobe -v iio-trig-sysfs
sudo su -c "echo -n 0 >/sys/bus/iio/devices/iio_sysfs_trigger/add_trigger"

# associate trigger with iio device
sudo su -c "echo -n sysfstrig0 > /sys/bus/iio/devices/iio:device0/trigger/current_trigger"

# buffer setup
CHANNEL_DIR="/sys/bus/iio/devices/iio:device0/scan_elements"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_humidityrelative_en"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_temp_en"
sudo su -c "echo -n 1 > $CHANNEL_DIR/in_timestamp_en"
sudo su -c "echo -n 1 > /sys/bus/iio/devices/iio:device0/buffer/enable"

# Trigger events in sysfs with a frequency of 1/3 Hz that is appropriate
# for AM2315/ AM2321 according to datasheets.
while true; do
    sudo su -c "echo -n 0 > /sys/bus/iio/devices/trigger0/trigger_now"
    sleep 3
done
