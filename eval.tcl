# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 4;# number of mobilenodes
set val(rp) DSDV ;# routing protocol

set ns_ [new Simulator]
set tracefd [open simple.tr w]
$ns_ trace-all $tracefd
set namtrace [open out.nam w]
$ns_ namtrace-all-wireless $namtrace 500 500

set topo [new Topography]
$topo load_flatgrid 500 500

create-god $val(nn)

$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;
}

$node_(0) radius 100
$node_(1) radius 100
$node_(2) radius 100
$node_(3) radius 100

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
$node_(0) set X_ 30.0
$node_(0) set Y_ 1.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 30.0
$node_(1) set Y_ 100.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 100.0
$node_(2) set Y_ 50.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 250.0
$node_(3) set Y_ 50.0
$node_(3) set Z_ 0.0
# Now produce some simple node movements
$ns_ at 0.0 "$node_(0) setdest 30.0 1.0 0.0"
$ns_ at 0.0 "$node_(1) setdest 30.0 100.0 0.0"
$ns_ at 0.0 "$node_(2) setdest 200.0 90.0 1.0"
$ns_ at 0.0 "$node_(3) setdest 250.0 50.0 0.0"

$ns_ at 0.5 "$node_(2) setdest 40.0 20.0 0.0"
$ns_ at 2.5 "$node_(2) setdest 40.0 80.0 100.0"
$ns_ at 6.0 "$node_(2) setdest 40.0 20.0 0.0"

#$ns_ duplex-link $node_(0) $node_(2) 1Mb 10ms DropTail
#$ns_ duplex-link $node_(1) $node_(2) 1Mb 10ms DropTail
#$ns_ duplex-link $node_(2) $node_(3) 1Mb 10ms DropTail

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(3) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set udp [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp
set null [new Agent/Null]
$ns_ attach-agent $node_(3) $null
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

$ns_ at 0.1 "$ftp start"
$ns_ at 0.8 "$cbr start"

for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 10.0 "$node_($i) reset";
}
$ns_ at 10.0 "stop"
$ns_ at 10.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
exec nam out.nam &
}
puts "Starting Simulation..."
$ns_ run