#Given a variable name and year-month-day-run as environmental variables download and merges the variable
################################################
set -e

listurls() {
	filename="$1"
	url="$2"
	wget -qO- $url | grep -Eoi '<a [^>]+>' | \
	grep -Eo 'href="[^\"]+"' | \
	grep -Eo $filename | \
	xargs -I {} echo "$url"{}
}
export -f listurls
#
get_and_extract_one() {
  url="$1"
  file=`basename $url | sed 's/\.bz2//g'`
  if [ ! -f "$file" ]; then
  	wget -t 2 -q -O - "$url" | bzip2 -dc > "$file"
  fi
}
export -f get_and_extract_one
##############################################
download_merge_2d_variable_icon_d2()
{
	filename="icon-d2_germany_regular-lat-lon_single-level_${year}${month}${day}${run}_*_2d_${1}.grib2"
	filename_grep="icon-d2_germany_regular-lat-lon_single-level_${year}${month}${day}${run}_(.*)_2d_${1}.grib2.bz2"
	url="https://opendata.dwd.de/weather/nwp/icon-d2/grib/${run}/${1}/"
	if [ ! -f "${1}_${year}${month}${day}${run}_de.nc" ]; then
		listurls $filename_grep $url | parallel -j 1 get_and_extract_one {}
		cdo -f nc copy -seltime,00:00,01:00,02:00,03:00,04:00,05:00,06:00,07:00,08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00,18:00,19:00,20:00,21:00,22:00,23:00 -mergetime ${filename} ${1}_${year}${month}${day}${run}_de.nc
		rm ${filename}
	fi
}
export -f download_merge_2d_variable_icon_d2
##############################################
download_merge_3d_variable_icon_d2()
{
	filename="icon-d2_germany_regular-lat-lon_pressure-level_${year}${month}${day}${run}_*_${1}.grib2"
	filename_grep="icon-d2_germany_regular-lat-lon_pressure-level_${year}${month}${day}${run}_(.*)_(950|850|700|500)_${1}.grib2.bz2"
	url="https://opendata.dwd.de/weather/nwp/icon-d2/grib/${run}/${1}/"
	if [ ! -f "${1}_${year}${month}${day}${run}_de.nc" ]; then
		listurls $filename_grep $url | parallel -j 1 get_and_extract_one {}
		cdo merge ${filename} ${1}_${year}${month}${day}${run}_de.grib2
		rm ${filename}
		cdo -f nc copy -seltime,00:00,01:00,02:00,03:00,04:00,05:00,06:00,07:00,08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00,18:00,19:00,20:00,21:00,22:00,23:00 ${1}_${year}${month}${day}${run}_de.grib2 ${1}_${year}${month}${day}${run}_de.nc
		rm ${1}_${year}${month}${day}${run}_de.grib2
	fi
}
export -f download_merge_3d_variable_icon_d2
################################################
download_invariant_icon_d2()
{
	filename="icon-d2_germany_regular-lat-lon_time-invariant_${year}${month}${day}${run}_000_0_hsurf.grib2"
	wget -r -nH -np -nv -nd --reject "index.html*" --cut-dirs=3 -A "${filename}.bz2" "https://opendata.dwd.de/weather/nwp/icon-d2/grib/${run}/hsurf/"
	bzip2 -d ${filename}.bz2
	cdo -f nc copy ${filename} HSURF_${year}${month}${day}${run}_de.nc
	rm ${filename}
}
export -f download_invariant_icon_d2
