set rho 0.8
puts "rho = $rho"
 
set rng [new RNG]
$rng seed 69
set nssim [new Simulator]
 
set mfsize 500
 
set bnbw 10000000
 
set nof_tcps 100
set nof_classes 12
set rho_cl [expr $rho/$nof_classes]
 
set mpktsize 1460
 
puts "rho_cl = $rho_cl, nof_classes = $nof_classes"
 
set mean_intarrtime [expr ($mpktsize + 40) * 8.0 * $mfsize / ($bnbw * $rho_cl)]
 
puts "1/1a = $mean_intarrtime"
 
for {set ii 0} {$ii < $nof_classes} {incr ii} {
	set delres($ii) {}
	set nlist($ii) {}
	set freelist($ii) {}
	set reslist($ii) {}
}
 
Agent/TCP instproc done {} {
	global nssim freelist reslist ftp rng mfsize mean_intarrtime nof_tcps simstart simend delres nlist
 
	set flind [$self set fid_]
 
	set class [expr int(floor($flind / $nof_tcps))]
	set ind [expr $flind - $class * $nof_tcps]
 
	lappend nlist($class) [list [$nssim now] [llength $reslist($class)]]
	for {set nn 0} {$nn < [llength $reslist($class)]} {incr nn} {
		set tmp [lindex $reslist($class) $nn]
		set tmpind [lindex $tmp 0]
		if {$tmpind == $ind} {
			set mm $nn
			set starttime [lindex $tmp 1]
		}
	}
 
	set reslist($class) [lreplace $reslist($class) $mm $mm]
	lappend freelist($class) $ind
 
	set tt [$nssim now]
	if {$starttime > $simstart && $tt < $simend} {
		lappend delres($class) [expr $tt - $starttime]
	}
 
	if {$tt > $simend} {
		$nssim at $tt "$nssim halt"
	}
}
 
proc start_flow {class} {
	global nssim freelist reslist ftp tcp_s tcp_d rng nof_tcps mfsize mean_intarrtime simend
 
	set tt [$nssim now]
	set freeflows [llength $freelist($class)]
	set resflows [llength $reslist($class)]
 
	lappend nlist($class) [list $tt $resflows]
 
	if {$freeflows == 0} {
		puts " Class $class: AT $tt, nof free TCP sources == 0!!!"
		puts "freelist($class) = $freelist($class)"
		puts "reslist($class) = $reslist($class)"
	} else {
		set ind [lindex $freelist($class) 0]
		set cur_fsize [expr ceil([$rng exponential $mfsize])]
 
		#$tcp_s($class, $ind) reset
		set tc [lindex $tcp_s($class) $ind]
		$tc reset
		#$tcp_d($class, $ind) reset
		set tc [lindex $tcp_d($class) $ind]
		$tc reset
		#$ftp($class, $ind) produce $cur_fsize
		set tc [lindex $ftp($class) $ind]
 
		$nssim at $tt "$tc produce $cur_fsize"
 
		set freelist($class) [lreplace $freelist($class) 0 0]
		lappend reslist($class) [list $ind $tt $cur_fsize]
 
		set newarrtime [expr $tt + [$rng exponential $mean_intarrtime]]
		$nssim at $newarrtime "[start_flow $class]"
 
		if {$tt > $simend} {
			$nssim at $tt "[$nssim halt]"
		}
	}
}
 
set parr_start 0
set pdrops_start 0
 
proc record_start {} {
	global fmon_bn nssim parr_start pdrops_start nof_classes
 
	set parr_start [$fmon_bn set parrivals_]
	set pdrops_start [$fmon_bn set pdropd_]
	puts "Bottleneck at [$nssim now]: arr = $parr_start, drops = $pdrops_start"
}
 
set parr_end 0
set pdrops_end 0
 
proc record_end {} {
	global fmon_bn nssim parr_start pdrops_start nof_classes
	set parr_start [$fmon_bn set parrivals_]
	set pdrops_start [$fmon_bn set pdrops_]
	puts "Bottleneck at [$nssim now]: arr = $parr_start, drops = $pdrops_start"
}
 
$nssim color 1 Blue
$nssim color 2 Red
$nssim color 3 Green
$nssim color 4 Yellow
 
set n0 [$nssim node]
set n1 [$nssim node]
set n2 [$nssim node]
set n3 [$nssim node]
set n4 [$nssim node]
set n5 [$nssim node]
set n6 [$nssim node]
set n7 [$nssim node]
set n8 [$nssim node]
set n9 [$nssim node]
set n10 [$nssim node]
set n11 [$nssim node]
set n12 [$nssim node]
set n13 [$nssim node]
set n14 [$nssim node]
set n15 [$nssim node]
set n16 [$nssim node]
set n17 [$nssim node]
set n18 [$nssim node]
set n19 [$nssim node]
set n20 [$nssim node]
set n21 [$nssim node]
set n22 [$nssim node]
set n23 [$nssim node]
set n24 [$nssim node]
set n25 [$nssim node]
set n26 [$nssim node]
set n27 [$nssim node]
set n28 [$nssim node]
set n29 [$nssim node]
set n30 [$nssim node]
set n31 [$nssim node]
set n32 [$nssim node]
set n33 [$nssim node]
 
set nf [open out.nam w]
$nssim namtrace-all $nf
 
proc finish {} {
	global nssim nf
	$nssim flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}
 
$nssim duplex-link $n0 $n12 10Mb 10ms DropTail
$nssim duplex-link $n1 $n12 10Mb 10ms DropTail
$nssim duplex-link $n2 $n12 10Mb 10ms DropTail
 
$nssim duplex-link $n3 $n13 10Mb 10ms DropTail
$nssim duplex-link $n4 $n13 10Mb 10ms DropTail
$nssim duplex-link $n5 $n13 10Mb 10ms DropTail
 
$nssim duplex-link $n6 $n14 10Mb 10ms DropTail
$nssim duplex-link $n7 $n14 10Mb 10ms DropTail
$nssim duplex-link $n8 $n14 10Mb 10ms DropTail
 
$nssim duplex-link $n9 $n15 10Mb 10ms DropTail
$nssim duplex-link $n10 $n15 10Mb 10ms DropTail
$nssim duplex-link $n11 $n15 10Mb 10ms DropTail
 
$nssim duplex-link $n21 $n33 10Mb 10ms DropTail
$nssim duplex-link $n21 $n32 10Mb 10ms DropTail
$nssim duplex-link $n21 $n31 10Mb 10ms DropTail
 
$nssim duplex-link $n20 $n30 10Mb 10ms DropTail
$nssim duplex-link $n20 $n29 10Mb 10ms DropTail
$nssim duplex-link $n20 $n28 10Mb 10ms DropTail
 
$nssim duplex-link $n19 $n27 10Mb 10ms DropTail
$nssim duplex-link $n19 $n26 10Mb 10ms DropTail
$nssim duplex-link $n19 $n25 10Mb 10ms DropTail
 
$nssim duplex-link $n18 $n24 10Mb 10ms DropTail
$nssim duplex-link $n18 $n23 10Mb 10ms DropTail
$nssim duplex-link $n18 $n22 10Mb 10ms DropTail
 
$nssim duplex-link $n12 $n16 100Mb 5ms DropTail
$nssim duplex-link $n13 $n16 100Mb 20ms DropTail
$nssim duplex-link $n14 $n16 100Mb 35ms DropTail
$nssim duplex-link $n15 $n16 100Mb 50ms DropTail
 
$nssim duplex-link $n17 $n21 100Mb 5ms DropTail
$nssim duplex-link $n17 $n20 100Mb 20ms DropTail
$nssim duplex-link $n17 $n19 100Mb 35ms DropTail
$nssim duplex-link $n17 $n18 100Mb 50ms DropTail
 
$nssim duplex-link $n16 $n17 10Mb 30ms DropTail
 
$nssim queue-limit $n0 $n12 100
$nssim queue-limit $n1 $n12 100
$nssim queue-limit $n2 $n12 100
 
$nssim queue-limit $n3 $n13 100
$nssim queue-limit $n4 $n13 100
$nssim queue-limit $n5 $n13 100
 
$nssim queue-limit $n6 $n14 100
$nssim queue-limit $n7 $n14 100
$nssim queue-limit $n8 $n14 100
 
$nssim queue-limit $n9 $n15 100
$nssim queue-limit $n10 $n15 100
$nssim queue-limit $n11 $n15 100
 
$nssim queue-limit $n21 $n33 100
$nssim queue-limit $n21 $n32 100
$nssim queue-limit $n21 $n31 100
 
$nssim queue-limit $n20 $n30 100
$nssim queue-limit $n20 $n29 100
$nssim queue-limit $n20 $n28 100
 
$nssim queue-limit $n19 $n27 100
$nssim queue-limit $n19 $n26 100
$nssim queue-limit $n19 $n25 100
 
$nssim queue-limit $n18 $n24 100
$nssim queue-limit $n18 $n23 100
$nssim queue-limit $n18 $n22 100
 
$nssim queue-limit $n12 $n16 100
$nssim queue-limit $n13 $n16 100
$nssim queue-limit $n14 $n16 100
$nssim queue-limit $n15 $n16 100
 
$nssim queue-limit $n17 $n21 100
$nssim queue-limit $n17 $n20 100
$nssim queue-limit $n17 $n19 100
$nssim queue-limit $n17 $n18 100
 
$nssim queue-limit $n16 $n17 100
 
set tcp_s(0) {}
set tcp_s(1) {}
set tcp_s(2) {}
set tcp_s(3) {}
set tcp_s(4) {}
set tcp_s(5) {}
set tcp_s(6) {}
set tcp_s(7) {}
set tcp_s(8) {}
set tcp_s(9) {}
set tcp_s(10) {}
set tcp_s(11) {}
 
set tcp_d(0) {}
set tcp_d(1) {}
set tcp_d(2) {}
set tcp_d(3) {}
set tcp_d(4) {}
set tcp_d(5) {}
set tcp_d(6) {}
set tcp_d(7) {}
set tcp_d(8) {}
set tcp_d(9) {}
set tcp_d(10) {}
set tcp_d(11) {}
 
set ftp(0) {}
set ftp(1) {}
set ftp(2) {}
set ftp(3) {}
set ftp(4) {}
set ftp(5) {}
set ftp(6) {}
set ftp(7) {}
set ftp(8) {}
set ftp(9) {}
set ftp(10) {}
set ftp(11) {}
 
set nodes(0) $n0
set nodes(1) $n1
set nodes(2) $n2
set nodes(3) $n3
set nodes(4) $n4
set nodes(5) $n5
set nodes(6) $n6
set nodes(7) $n7
set nodes(8) $n8
set nodes(9) $n9
set nodes(10) $n10
set nodes(11) $n11
 
set nodes(12) $n22
set nodes(13) $n23
set nodes(14) $n24
set nodes(15) $n25
set nodes(16) $n26
set nodes(17) $n27
set nodes(18) $n28
set nodes(19) $n29
set nodes(20) $n30
set nodes(21) $n31
set nodes(22) $n32
set nodes(23) $n33
 
for {set ii 0} {$ii < 12} {incr ii} {
	for {set jj 0} {$jj < 100} {incr jj} {
		set tcp [new Agent/TCP/Reno]
		$tcp set class_ $ii
		$tcp set fid_ [expr 100 * $ii + $jj] 
		$tcp set window_ 1000
		$tcp set packetSize_ 1460
		$nssim attach-agent $nodes($ii) $tcp
		set sink [new Agent/TCPSink]
		$nssim attach-agent $nodes([expr 23 - $ii]) $sink
		$nssim connect $tcp $sink
		set ftpp [new Application/FTP]
		$ftpp attach-agent $tcp
		$ftpp set type_ FTP
		lappend tcp_s($ii) $tcp
		lappend tcp_d($ii) $sink
		lappend freelist($ii) $jj
		lappend ftp($ii) $ftpp
 
	}
}
 
set simstart 0.5
set simend 4.5
 
for {set ii 0} {$ii < 12} {incr ii} {
	$nssim at 0.02 ["start_flow" $ii]
}
 
$nssim at 5.0 "finish"
 
$nssim run