extends Node

#warning-ignore:unused_signal
signal IdeCpuDebugLine(line)

func connect_signal(tSignal: String, target: Object, method: String):
	#warning-ignore:return_value_discarded
	connect(tSignal, target, method)

