set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
set nf [open out.nam w]
$ns namtrace-all $nf
proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0 
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns duplex-link $n0 $n4 2Mb 10ms DropTail
$ns duplex-link $n1 $n4 2Mb 10ms DropTail
$ns duplex-link $n4 $n2 1.7Mb 20ms DropTail
$ns duplex-link $n4 $n3 1.7Mb 20ms DropTail

$ns queue-limit $n4 $n2 10
$ns queue-limit $n4 $n3 10

$ns duplex-link-op $n0 $n4 orient right-down
$ns duplex-link-op $n1 $n4 orient right-up
$ns duplex-link-op $n2 $n4 orient left-down
$ns duplex-link-op $n3 $n4 orient left-up

$ns duplex-link-op $n4 $n2 queuePos 0.5 
$ns duplex-link-op $n4 $n3 queuePos 0.5

set udp1 [new Agent/UDP]
$ns attach-agent $n0 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n3 $null1
$ns connect $udp1 $null1
$udp1 set fid_ 1

set udp2 [new Agent/UDP]
$ns attach-agent $n1 $udp2
set null2 [new Agent/Null]
$ns attach-agent $n2 $null2
$ns connect $udp2 $null2
$udp2 set fid_ 2

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 1mb
$cbr1 set random_ false

set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

$ns at 0.1 "$cbr1 start"
$ns at 1.0 "$cbr2 start"
$ns at 4.0 "$cbr2 stop"
$ns at 4.5 "$cbr1 stop"

$ns at 4.5 "$ns detach-agent $n0 $udp1 ; $ns detach-agent $n3 $null1"
$ns at 5.0 "finish"

$ns run

