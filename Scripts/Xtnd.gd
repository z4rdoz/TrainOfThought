extends Node

func getLineIntersection(x1, y1, x2, y2, x3, y3, x4, y4):
	# ported from paul bourke's formula:
	# http://paulbourke.net/geometry/pointlineplane
	#check if any lines are length 0
	if (x1 == x2 and y1 == y2) or (x3 == x4 and y3 == y4):
		return null

	var denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))

	#lines are parallel
	if denominator == 0:
		return null

	var ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
	var ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

	# is the intersection along the segments
	if (ua < 0 or ua > 1 or ub < 0 or ub > 1):
		return null	

  	# Return a object with the x and y coordinates of the intersection
	var x = x1 + ua * (x2 - x1)
	var y = y1 + ua * (y2 - y1)

	return Vector2(x, y)