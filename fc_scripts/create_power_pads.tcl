set cells_to_create [join "
iovdd_left
iovdd_right
iovdd_bottom
iovdd_top
"]
foreach c $cells_to_create {
	create_cell $c [get_lib_cells */PVDD2DGZ]
}

set cells_to_create [join "
iovss_left
iovss_right
iovss_bottom
iovss_top
"]
foreach c $cells_to_create {
	create_cell $c [get_lib_cells */PVSS2DGZ]
}

set cells_to_create [join "
vdd_left
vdd_right
vdd_bottom
vdd_top
"]
foreach c $cells_to_create {
	create_cell $c [get_lib_cells */PVDD1DGZ]
}


set cells_to_create [join "
vss_left
vss_right
vss_bottom
vss_top
"]
foreach c $cells_to_create {
	create_cell $c [get_lib_cells */PVSS1DGZ]
}