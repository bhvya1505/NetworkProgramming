set ns [new Simulator]
$ns at 1 "puts \"hello world\""
$ns at 1.5 "exit"
$ns run 