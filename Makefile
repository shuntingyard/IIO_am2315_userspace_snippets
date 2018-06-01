default:
	@echo Building executable ...
	gcc ./src/catiio.c -o catiio

clean:
	@echo Cleaning up ...
	-rm catiio
