set opt(adhocRouting)   DSDV
set opt(cp)     	""       ;# cp file not used
set opt(stop)   	10    ;# time to stop simulation
set opt(ftp1-start)      2.0;
set opt(ftp2-start)      3.0;
set opt(x) 	500;
set opt(y) 	500;
set opt(ll)	LL;
set opt(ifq) Queue/DropTail/PriQueue ;
set opt(ifqlen) 50 ;
set opt(ant) Antenna/OmniAntenna ;
set opt(mac) Mac/802_11 ;
set opt(prop) Propagation/TwoRayGround ;
set opt(netif) Phy/WirelessPhy ;
set opt(chan) Channel/WirelessChannel ;
set num_wired_nodes      2;
set num_bs_nodes         1;
set opt(nn)	2;

set ns_ [new Simulator]
$ns_ node-config -addressType hierarchical    
AddrParams set domain_num_ 2           ;# number of domains
lappend cluster_num 2 1                ;# number of clusters in each
                                       ;#domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 4              ;# number of nodes in each cluster
AddrParams set nodes_num_ $eilastlevel ;# for each domain

set tracefd  [open wireless2-out.tr w]
set namtrace [open wireless2-out.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

create-god 5

# create wired nodes
set temp {0.0.0 0.1.0}           ;# hierarchical addresses to be used
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]]
}
# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3}   ;# hier address to be used for
                                     ;# wireless domain
set BS(0) [ $ns_ node [lindex $temp 0]]
$BS(0) random-motion 0               ;# disable random motion

#provide some co-ordinates (fixed) to base station node
$BS(0) set X_ 1.0
$BS(0) set Y_ 2.0
$BS(0) set Z_ 0.0

# create mobilenodes in the same domain as BS(0)
# note the position and movement of mobilenodes is as defined
# in $opt(sc)
# Note there has been a change of the earlier AddrParams 
# function 'set-hieraddr' to 'addr2id'.

#configure for mobilenodes
$ns_ node-config -wiredRouting OFF

# now create mobilenodes
for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
            [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id \
            [$BS(0) node-addr]]   ;# provide each mobilenode with
                                  ;# hier address of its base-station
}

$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0

$ns_ at 5.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns_ at 1.0 "$node_(0) setdest 20.0 18.0 1.0"

# Node_(1) then starts to move away from node_(0)
$ns_ at 6.0 "$node_(1) setdest 490.0 480.0 15.0" 

#create links between wired and BS nodes      
$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail

$ns_ duplex-link-op $W(0) $W(1) orient down
$ns_ duplex-link-op $W(1) $BS(0) orient left-down

# setup TCP connections
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $W(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $opt(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $W(1) $tcp2        
$ns_ attach-agent $node_(1) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at $opt(ftp2-start) "$ftp2 start"

proc stop {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
exec nam wireless2-out.nam &
}

$ns_ at $opt(stop) "stop"
$ns_ run
