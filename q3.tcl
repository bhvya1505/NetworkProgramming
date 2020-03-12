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
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
set n11 [$ns node]

$ns duplex-link $n0 $n2 10Mb 20ms DropTail
$ns duplex-link $n0 $n3 10Mb 20ms DropTail
$ns duplex-link $n0 $n4 10Mb 20ms DropTail
$ns duplex-link $n0 $n5 10Mb 20ms DropTail
$ns duplex-link $n0 $n6 10Mb 20ms DropTail

$ns duplex-link $n1 $n7 10Mb 20ms DropTail
$ns duplex-link $n1 $n8 10Mb 20ms DropTail
$ns duplex-link $n1 $n9 10Mb 20ms DropTail
$ns duplex-link $n1 $n10 10Mb 20ms DropTail
$ns duplex-link $n1 $n11 10Mb 20ms DropTail

$ns duplex-link $n0 $n1 1.5Mb 40ms DropTail

$ns duplex-link-op $n1 $n0 orient right

$ns duplex-link-op $n2 $n0 orient up
$ns duplex-link-op $n3 $n0 orient left-up
$ns duplex-link-op $n4 $n0 orient left
$ns duplex-link-op $n5 $n0 orient left-down
$ns duplex-link-op $n6 $n0 orient down

$ns duplex-link-op $n7 $n1 orient up
$ns duplex-link-op $n8 $n1 orient right-up
$ns duplex-link-op $n9 $n1 orient right
$ns duplex-link-op $n10 $n1 orient right-down
$ns duplex-link-op $n11 $n1 orient down


set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n0 $tcp1 
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP 

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n2 $tcp2 
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP 

$ns at 0.1 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 4.0 "$ftp2 stop"
$ns at 4.5 "$ftp1 stop"

$ns at 4.5 "$ns detach-agent $n0 $tcp1 ; $ns detach-agent $n1 $sink1"
$ns at 5.0 "finish"

$ns run

