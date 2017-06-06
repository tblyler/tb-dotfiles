# convert integer to IP
int2ip () {
	local ip dec=$@
	for e in {3..0}
	do
		((octet = dec / (256 ** e) ))
		((dec -= octet * 256 ** e))
		ip+=$delim$octet
		delim=.
	done
	printf '%s\n' "$ip"
	unset delim
}

# convert IP to integer
ip2int () {
	local a b c d ip=$@
	IFS=. read -r a b c d <<< "$ip"
	printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
}
