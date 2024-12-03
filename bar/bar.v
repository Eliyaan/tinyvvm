import os

fn main() {
	audio := audio_get()
	disk := disk_get()
	wifi := wifi_get()
	network := network_get()
	memory := mem_get()
	brightness := bright_get()
	battery := bat_get()
	bluetooth := blue_get()
	println('\U0001F50A ${audio} | \U0001F4BE ${disk} | 🌐 ${wifi} ${network} | Mem: ${memory} | ⏾ ${brightness} | \U0001F50B ${battery} | \uF293 ${bluetooth}') // use unicode
}

fn disk_get() string {
	df := os.execute('df -h /').output
	without := df[df.index('%') or { 0 } + 1..]
	i := without.index('%') or { 0 }
	return without[i - 3..i + 1]
}

fn audio_get() string {
	amixer := os.execute('pamixer --get-volume').output
	return amixer#[..-1]
}

fn wifi_get() string {
	enabled := os.execute('nmcli r wifi').output
	return if enabled.contains('enabled') {
		'on'
	} else {
		'off'
	}
}

fn network_get() string {
	network := os.execute('nmcli -t -f NAME connection show --active').output.split('\n')[0]
	if network == 'lo' {
		return '-'
	}
	return network
}

fn mem_get() string {
	return os.execute('free | awk \'NR==2 {printf "%.1f/%.1fGo", $3/1000000.0, $2/1000000.0}\'').output
}

fn bright_get() string {
	return os.execute('brightnessctl | awk \'NR==2 {printf "%.0f%", $3/960}\'').output
}

fn bat_get() string {
	return os.execute("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage'").output#[-4..-1]
}

fn blue_get() string {
	return os.execute("bluetoothctl show | awk 'NR==7 {printf $2}'").output
}
