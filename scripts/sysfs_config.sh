#! /bin/bash

# TODO
#
# - Add some sort of logging about steps accomplished.
# - Add more detailed comments/ explanations.
#


# I2C bus
#
i2c_bus="i2c-1"	    # This is for Raspberry Pi, adapt to your system.


# You might want to adapt these if your IIO subsystem contains more than
# present configuration
#
t_index=0	    # IIO device index
d_index=0	    # IIO sysfs trigger index


PROMPT="[sudo] please let me have your password: "
MODULE="am2315"
I2C_ADDR=0x5c
IIO_DEV_PATH="/sys/bus/iio/devices/iio:device$d_index"


case "$1" in

    "setup")
	sudo -v -p "$PROMPT"

	# load am2315
	sudo modprobe -v "$MODULE"

	# create new i2c device on proper bus
	sudo su -c "echo -n "$MODULE" $I2C_ADDR > /sys/bus/i2c/devices/$i2c_bus/new_device"

	# trigger setup
	sudo modprobe -v iio-trig-sysfs
	sudo su -c "echo -n $t_index >/sys/bus/iio/devices/iio_sysfs_trigger/add_trigger"

	# associate trigger with iio device
	sudo su -c "echo -n sysfstrig$t_index > $IIO_DEV_PATH/trigger/current_trigger"

	# buffer setup (enable desired channels before enabling buffer)
	sudo su -c "echo -n 1 > $IIO_DEV_PATH/scan_elements/in_humidityrelative_en"
	sudo su -c "echo -n 1 > $IIO_DEV_PATH/scan_elements/in_temp_en"
	sudo su -c "echo -n 1 > $IIO_DEV_PATH/scan_elements/in_timestamp_en"
	sudo su -c "echo -n 1 > $IIO_DEV_PATH/buffer/enable"

	# Trigger events in sysfs with a frequency of 1/3 Hz that is appropriate
	# for AM2315/ AM2321 according to datasheets.
	while true; do
	    sudo su -c "echo -n 0 > /sys/bus/iio/devices/trigger0/trigger_now"
	    sleep 3
	done
	;;

    "teardown")
	sudo -v -p "$PROMPT"

	# buffer teardown
	sudo su -c "echo -n 0 > $IIO_DEV_PATH/buffer/enable"
	sudo su -c "echo -n 0 > $IIO_DEV_PATH/scan_elements/in_humidityrelative_en"
	sudo su -c "echo -n 0 > $IIO_DEV_PATH/scan_elements/in_temp_en"
	sudo su -c "echo -n 0 > $IIO_DEV_PATH/scan_elements/in_timestamp_en"

	# unassociate trigger (by removing triggered device)
	sudo su -c "echo -n $I2C_ADDR > /sys/bus/i2c/devices/$i2c_bus/delete_device"

	# trigger teardown
	sudo su -c "echo -n $t_index >/sys/bus/iio/devices/iio_sysfs_trigger/remove_trigger"
	sudo modprobe -rv iio-trig-sysfs

	# unload am235
	sudo modprobe -rv "$MODULE"
	;;

    *)
	echo "Usage: $(basename "$0") setup | teardown"
	;;

esac
