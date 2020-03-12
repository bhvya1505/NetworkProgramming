# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 3;# number of mobilenodes
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

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
$node_(0) set X_ 30.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 400.0
$node_(1) set Y_ 450.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 200.0
$node_(2) set Y_ 250.0
$node_(2) set Z_ 0.0
# Now produce some simple node movements
$ns_ at 0.0 "$node_(0) setdest 30.0 50.0 20.0"
$ns_ at 0.0 "$node_(1) setdest 400.0 450.0 80.0"
$ns_ at 0.0 "$node_(2) setdest 200.0 250.0 1.0"

$ns_ at 0.5 "$node_(0) setdest 190.0 210.0 100.0"
$ns_ at 0.5 "$node_(1) setdest 220.0 280.0 100.0"

$ns_ at 55.5 "$node_(0) setdest 30.0 50.0 100.0"
$ns_ at 55.5 "$node_(1) setdest 400.0 450.0 100.0"

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(2) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp2
$ns_ attach-agent $node_(2) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns_ at 2.0 "$ftp start"
$ns_ at 2.0 "$ftp2 start"

for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
exec nam out.nam &
}
puts "Starting Simulation..."
$ns_ run