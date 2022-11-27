set rho 0.8
puts "rho = $rho"
 
set rng [new RNG]
$rng seed 69
set nssim [new Simulator]
 
set mfsize 500
 
set bnbw 10000000
 
set nof_tcps 100
set nof_classes 4
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
 
$nssim color 1 Pink
$nssim color 2 Red
$nssim color 3 Green
$nssim color 4 Blue
 
set n0 [$nssim node]
set n1 [$nssim node]
set n2 [$nssim node]
set n3 [$nssim node]
set n4 [$nssim node]
set n5 [$nssim node]
 
set nf [open out.nam w]
$nssim namtrace-all $nf
 
proc finish {} {
	global nssim nf
	$nssim flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}
 
$nssim duplex-link $n0 $n4 100Mb 10ms DropTail
$nssim duplex-link $n1 $n4 100Mb 40ms DropTail
$nssim duplex-link $n2 $n4 100Mb 70ms DropTail
$nssim duplex-link $n3 $n4 100Mb 100ms DropTail
$nssim duplex-link $n4 $n5 10Mb 10ms DropTail
 
$nssim queue-limit $n0 $n4 1000
$nssim queue-limit $n1 $n4 1000
$nssim queue-limit $n2 $n4 1000
$nssim queue-limit $n3 $n4 1000
$nssim queue-limit $n4 $n5 1000
 
$nssim duplex-link-op $n0 $n4 orient down
$nssim duplex-link-op $n1 $n4 orient right-down
$nssim duplex-link-op $n2 $n4 orient right-up
$nssim duplex-link-op $n3 $n4 orient up
$nssim duplex-link-op $n4 $n5 orient right
 
set tcp_s(0) {}
set tcp_s(1) {}
set tcp_s(2) {}
set tcp_s(3) {}
 
set tcp_d(0) {}
set tcp_d(1) {}
set tcp_d(2) {}
set tcp_d(3) {}
 
set ftp(0) {}
set ftp(1) {}
set ftp(2) {}
set ftp(3) {}
 
set nodes(0) $n0
set nodes(1) $n1
set nodes(2) $n2
set nodes(3) $n3
 
for {set ii 0} {$ii < 4} {incr ii} {
	for {set jj 0} {$jj < 100} {incr jj} {
		set tcp [new Agent/TCP/Reno]
		$tcp set class_ $ii
		$tcp set fid_ [expr 100 * $ii + $jj]
		$tcp set window_ 1000
		$tcp set packetSize_ 1460
		$nssim attach-agent $nodes($ii) $tcp
		set sink [new Agent/TCPSink]
		$nssim attach-agent $n5 $sink
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
 
set simstart 5
set simend 50
 
for {set ii 0} {$ii < 4} {incr ii} {
	$nssim at 0.02 ["start_flow" $ii]
}

$nssim at 5.0 "finish"

$nssim run