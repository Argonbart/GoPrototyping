class_name SBConstraint extends Object


var p1: SBPoint
var p2: SBPoint 

var desired_length: float
var stiffness: float


func _init(p_1: SBPoint, p_2: SBPoint, length: float, stiff: float = 1):
	p1 = p_1
	p2 = p_2
	desired_length = length
	stiffness = stiff
