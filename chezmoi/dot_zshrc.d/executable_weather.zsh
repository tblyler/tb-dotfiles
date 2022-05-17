#!/usr/bin/zsh

function weather_check_requirements() {
	[ -r "$(_weather_api_key_path)" ] && \
	[ -r "$(_weather_home_location_key_path)" ] && \
	command -v jq &> /dev/null && \
	command -v curl &> /dev/null && \
	command -v touch &> /dev/null && \
	command -v mktemp &> /dev/null
}

function weather_short_status() {
	(
		set -euo pipefail

		API_KEY_PATH="$(_weather_api_key_path)"
		if ! [ -r "${API_KEY_PATH}" ]; then
			read -r 'RESPONSE?Accuweather API key: '
			echo "Storing key at ${API_KEY_PATH}"
			echo "${RESPONSE}" > "${API_KEY_PATH}"
		fi

		WEATHER_API_KEY="$(< "${API_KEY_PATH}")"

		HOME_LOCATION_KEY_PATH="$(_weather_home_location_key_path)"
		if ! [ -r "${HOME_LOCATION_KEY_PATH}" ]; then
			read -r 'RESPONSE?Accuweather location key for your home: '
			echo "Storing home location key at ${HOME_LOCATION_KEY_PATH}"
			echo "${RESPONSE}" > "${HOME_LOCATION_KEY_PATH}"
		fi

		WEATHER_LOCATION_KEY="$(< "${HOME_LOCATION_KEY_PATH}")"

		_weather_current_conditions | jq -r "$(<<'EOF'
first |
[
	"RF:"+(.RealFeelTemperature.Imperial.Value | tostring)+"°",
	"RFS:"+(.RealFeelTemperatureShade.Imperial.Value | tostring)+"°",
	"A:"+(.Temperature.Imperial.Value | tostring)+"°",
	(.RelativeHumidity | tostring)+"%",
	(.Wind.Speed.Imperial.Value | tostring)+"mph",
	.WeatherText,
	.PrecipitationType
] |
join(" ") |
rtrimstr(" ")
EOF
		)"
	)
}

function _weather_cache_dir() {
	local -r CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/weather"
	mkdir -p "${CACHE_DIR}" || return $?

	echo "${CACHE_DIR}"
}

function _weather_config_dir() {
	local -r CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/weather"
	mkdir -p "${CONFIG_DIR}" || return $?

	echo "${CONFIG_DIR}"
}

function _weather_api_key_path() {
	(
		set -euo pipefail
		echo "$(_weather_config_dir)/api_key.txt"
	)
}

function _weather_home_location_key_path() {
	(
		set -euo pipefail
		echo "$(_weather_config_dir)/home_location_key.txt"
	)
}

function _weather_api_key() {
	(
		set -euo pipefail
		> /dev/stdout < "$(_weather_api_key_path)"
	)
}

function _weather_cache_dir_location() {
	if [ "${WEATHER_LOCATION_KEY:-}" = "" ]; then
		>&2 echo "Must supply WEATHER_LOCATION_KEY"
		return 1
	fi

	local CACHE_DIR
	CACHE_DIR="$(_weather_cache_dir)/${WEATHER_LOCATION_KEY}"

	mkdir -p "${CACHE_DIR}" || return $?

	echo "${CACHE_DIR}"
}

function _weather_file_ctime() {
	if [ -z "${1:-}" ]; then
		>&2 echo 'Must supply a file path'
		return 1
	fi

	local FILE_STAT

	zstat -H FILE_STAT "${1}" || return $?

	echo "${FILE_STAT[ctime]}"
}

function _weather_file_size() {
	if [ -z "${1:-}" ]; then
		>&2 echo 'Must supply a file path'
		return 1
	fi

	local FILE_STAT

	zstat -H FILE_STAT "${1}" || return $?

	echo "${FILE_STAT[size]}"
}

function _weather_current_conditions() {
	(
		set -euo pipefail

		CURRENT_WEATHER_CACHE_FILE="$(_weather_cache_dir_location)/current_conditions.json"

		touch "${CURRENT_WEATHER_CACHE_FILE}"
		CTIME="$(_weather_file_ctime "${CURRENT_WEATHER_CACHE_FILE}")"
		SIZE="$(_weather_file_size "${CURRENT_WEATHER_CACHE_FILE}")"

		# has it been less than 20 minutes since the last update?
		if [ $((EPOCHSECONDS-CTIME)) -lt 1200 ] && [ "${SIZE}" != "0" ]; then
			> /dev/stdout < "${CURRENT_WEATHER_CACHE_FILE}"
			return
		fi

		TEMP_OUTPUT="$(mktemp)"
		trap 'rm -f "${TEMP_OUTPUT}"' EXIT

		curl -LSsf --get -X GET \
			--data-urlencode "apikey=${WEATHER_API_KEY}" \
			--data-urlencode "language=en-us" \
			--data-urlencode "details=true" \
			"https://dataservice.accuweather.com/currentconditions/v1/${WEATHER_LOCATION_KEY}" \
			-o "${TEMP_OUTPUT}"

		mv -f "${TEMP_OUTPUT}" "${CURRENT_WEATHER_CACHE_FILE}"
		> /dev/stdout < "${CURRENT_WEATHER_CACHE_FILE}"
	)
}

function _weather_12_hour_forecast() {
	(
		set -euo pipefail

		TWELVE_HOUR_FORECAST_CACHE_FILE="$(_weather_cache_dir_location)/12_hour_forecast.json"

		touch "${TWELVE_HOUR_FORECAST_CACHE_FILE}"
		CTIME="$(_weather_file_ctime "${TWELVE_HOUR_FORECAST_CACHE_FILE}")"
		SIZE="$(_weather_file_size "${TWELVE_HOUR_FORECAST_CACHE_FILE}")"

		# has it been less than 3 hours since the last update?
		if [ $((EPOCHSECONDS-CTIME)) -lt 10800 ] && [ "${SIZE}" != "0" ]; then
			> /dev/stdout < "${TWELVE_HOUR_FORECAST_CACHE_FILE}"
			return
		fi

		TEMP_OUTPUT="$(mktemp)"
		trap 'rm -f "${TEMP_OUTPUT}"' EXIT

		curl -LSsf --get -X GET \
			--data-urlencode "apikey=${WEATHER_API_KEY}" \
			--data-urlencode "language=en-us" \
			--data-urlencode "details=true" \
			"https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/${WEATHER_LOCATION_KEY}" \
			-o "${TEMP_OUTPUT}"

		mv -f "${TEMP_OUTPUT}" "${TWELVE_HOUR_FORECAST_CACHE_FILE}"
		> /dev/stdout < "${TWELVE_HOUR_FORECAST_CACHE_FILE}"
	)
}

function _weather_5_day_daily_forecast() {
	(
		set -euo pipefail

		FIVE_DAY_DAILY_FORECAST_CACHE_FILE="$(_weather_cache_dir_location)/5_day_daily_forecast.json"

		touch "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}"
		CTIME="$(_weather_file_ctime "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}")"
		SIZE="$(_weather_file_size "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}")"

		# has it been less than 12 hours since the last update?
		if [ $((EPOCHSECONDS-CTIME)) -lt 43200 ] && [ "${SIZE}" != "0" ]; then
			> /dev/stdout < "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}"
			return
		fi

		TEMP_OUTPUT="$(mktemp)"
		trap 'rm -f "${TEMP_OUTPUT}"' EXIT

		curl -LSsf --get -X GET \
			--data-urlencode "apikey=${WEATHER_API_KEY}" \
			--data-urlencode "language=en-us" \
			--data-urlencode "details=true" \
			"https://dataservice.accuweather.com/forecasts/v1/daily/5day/${WEATHER_LOCATION_KEY}" \
			-o "${TEMP_OUTPUT}"

		mv -f "${TEMP_OUTPUT}" "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}"
		> /dev/stdout < "${FIVE_DAY_DAILY_FORECAST_CACHE_FILE}"
	)
}
