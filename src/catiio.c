#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#define	BUF_LENGTH		16
#define	LSB_RH			 0
#define	MSB_RH			 1
#define	LSB_T			 2
#define	MSB_T			 3
#define LSB_TS			 8


/*@null@*/
static FILE *fp = NULL;


static void usage () {

    printf("Usage: catiio DEVICE_PATH\n");
    if ( errno != 0 )
        perror("fopen");
    exit(EXIT_FAILURE);
}

/**
 * Helper for bit shifting 64-bit integers
 */
static uint64_t lshift64 (char c, int bytes) {

    uint64_t uint64 = 0;
    uint64 |= c;
    int i;

    for ( i = 0; i < bytes; i++ ) {
        uint64 <<= 8;
    }
    return uint64;
}

static void tvtostr(char *str, size_t size, struct timeval tv) {

    time_t epoch_in;
    struct tm *tm_in;
    char tm_buf[64];

    epoch_in = tv.tv_sec;
    tm_in = localtime(&epoch_in);
    //strftime(tm_buf, sizeof tm_buf, "%Y-%m-%d %H:%M:%S", tm_in);
    (void) strftime(tm_buf, sizeof tm_buf, "%H:%M:%S", tm_in);
    (void) snprintf(str, size, "%s.%03ld", tm_buf, tv.tv_usec / 1000);
}

int main (int argc, char* argv[]) {

    int16_t RH_raw, T_raw;
    int64_t ts_raw;
    struct timeval ts = { 0 };
    char buf[BUF_LENGTH], timestr[64];

    // validate input args
    if ( argc != 2 )
        usage();
    fp = fopen(argv[1], "rb");
    if ( !fp )
        usage();
    else {

        while ( feof(fp) == 0 ) {
            (void) fread(buf, BUF_LENGTH, 1, fp);
            if ( ferror(fp) != 0 ) {
                perror("fread");
                exit(EXIT_FAILURE);
            }
            RH_raw = (int16_t) buf[MSB_RH] << 8 | buf[LSB_RH];
            T_raw  = (int16_t) buf[MSB_T]  << 8 | buf[LSB_T];

            ts_raw = (int64_t)
                     lshift64(buf[LSB_TS+0], 0) |
                     lshift64(buf[LSB_TS+1], 1) |
                     lshift64(buf[LSB_TS+2], 2) |
                     lshift64(buf[LSB_TS+3], 3) |
                     lshift64(buf[LSB_TS+4], 4) |
                     lshift64(buf[LSB_TS+5], 5) |
                     lshift64(buf[LSB_TS+6], 6) |
                     lshift64(buf[LSB_TS+7], 7) ;

            // iio timestamps are nanoseconds
            ts.tv_sec  = ts_raw / 1000000000LL;
            ts.tv_usec = ts_raw % 1000000000LL / 1000;

            /*@out@*/
            tvtostr(timestr, sizeof timestr, ts);
            printf("RH_raw %3d T_raw %6d ts_iio %"PRId64" "
                   "RH %4.1f T %+5.1f %s\n",
                   RH_raw, T_raw, ts_raw,
                   RH_raw / 10.0f,
		   /* T_raw has high order bit set for negative Celsius
		      temperatures (e.g. 0x8003 for -0.3°C). So we set
		      it to 0 change the sign :) */
		   T_raw < 0 ? (T_raw & 0x7fff) / -10.0f : T_raw / 10.0f,
		   timestr);
        }
    }
}
