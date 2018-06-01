# IIO_am2315_userspace_snippets

## What is this about?
One of the modules in the **Linux Industrial I/O Subsystem** (IIO) is called ``am2315``. It is used to drive I2C sensors for relative humidity and temperature - more specifically the devices known as AM2315 and Aosong AM2321.

While the I2C kernel space code for these devices is not too complicated to write and understand, it is a bit tricky at first glance and so far not documented in too much detail how to set up a working configuration in user space for the ``am2315`` kernel module.

The content of this repo provides simple examples documenting how to go about the setup task and how to read data conveyed by the ``am2315`` module and IIO subsystem.

## Content
### Scripts
There are one or two shell scripts with basic comments (see the scripts directory) as examples how to set up/ tear down a working IIO configuration for ``am2315`` and corresponding I2C devices.

### Utilities
The repo contains a very simple utility (``catiio``) for reading output (relative humidity, temperature and a timestamp) from the character device created by working setups for the AM2315 and AM2321 sensors.

## Technical notes
The I2C address used for AM2315 and AM2321 devices is always ``0x5c``. Therefore there can never exist more than one of these devices per I2C adapter or bus.

``catiio`` is essentially about decoding data channels with data types:
Data Type | Channel
--- | ---
> le:s16/16>>0 | in_humidityrelative_type
> le:s16/16>>0 | in_temp_type
> le:s64/64>>0 | in_timestamp_type
on the character device providing values from sensors.

REPO IS WORK IN PROGRESS UNTIL FURTHER NOTICE.
