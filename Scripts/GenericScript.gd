extends Node
class_name GenericScript

@export var properties : Array[String] # (Array,String)
@export var code = "" # (String,MULTILINE)

func _run(args = {"node":self}):
	Helper.run_script(code,args)

func run():
	print("Running")
	return _run()
	
func run1(arg1):
	var args = {}
	args[properties[0]] = arg1
	return _run(args)
	
	
func run2(arg1,arg2):
	var args = {}
	args[properties[0]] = arg1
	args[properties[1]] = arg2
	return _run(args)
	
func run3(arg1,arg2,arg3):
	var args = {}
	args[properties[0]] = arg1
	args[properties[1]] = arg2
	args[properties[2]] = arg3
	return _run(args)
	
	
func run4(arg1,arg2,arg3,arg4):
	var args = {}
	args[properties[0]] = arg1
	args[properties[1]] = arg2
	args[properties[2]] = arg3
	args[properties[3]] = arg4
	return _run(args)
	
func run5(arg1,arg2,arg3,arg4,arg5):
	var args = {}
	args[properties[0]] = arg1
	args[properties[1]] = arg2
	args[properties[2]] = arg3
	args[properties[3]] = arg4
	args[properties[4]] = arg5
	return _run(args)
	

