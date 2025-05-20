# ============================================================
# Author  :    Talha bin azmat - the honored one
# 
# Role    :    Hardware Design Engineer
# 
# Email   :    talhabinazmat@gmail.com
# 
# Contact :    +923325306662
# ============================================================





set_app_option -name plan.pgroute.disable_via_creation -value false

set_app_options -name plan.pgroute.max_undo_steps -value 100


create_pg_ring_pattern ring_pattern -horizontal_layer METAL5 \
   -horizontal_width {30} -horizontal_spacing {5} \
   -vertical_layer METAL4 -vertical_width {30} -vertical_spacing {5} -corner_bridge true

set_pg_strategy core_ring \
   -pattern {{name: ring_pattern} \
   {nets: {VDD VSS}} {offset: {5 5}}} -core 

compile_pg -strategies core_ring




set_app_options -name plan.pgroute.treat_pad_as_macro -value true

create_pg_macro_conn_pattern hm_pattern -pin_conn_type scattered_pin \
               -layers {METAL6 METAL6} -nets {VDD} -pin_layers {METAL1}

set_pg_strategy macro_conn_vdd -macros [get_cells vdd_*] -pattern {{name: hm_pattern} {nets: {VDD}}}


compile_pg -strategies {macro_conn_vdd} -ignore_via_drc


create_pg_macro_conn_pattern hm_pattern1 -pin_conn_type scattered_pin \
               -layers {METAL1 METAL1} -nets {VSS} -pin_layers {METAL1}

set_app_options -name plan.pgroute.treat_pad_as_macro -value true

set_pg_strategy macro_conn_vss -macros [get_cells vss_*] -pattern {{name: hm_pattern1} {nets: {VSS}}}

compile_pg -strategies macro_conn_vss


create_pg_ring_pattern imem_ring_pattern -nets {VDD VSS} -horizontal_layer METAL5 -vertical_layer METAL4 -horizontal_width {10} -vertical_width {10} -horizontal_spacing {4} -vertical_spacing {4} -track_alignment track -corner_bridge true
set_pg_strategy imem_ring_strategy_1 -macros $INST_MEM_INST -pattern {{pattern: imem_ring_pattern}{offset: 2}{nets: {VSS VDD}}}
compile_pg -strategies imem_ring_strategy_1


create_pg_ring_pattern dmem_ring_pattern -nets {VDD VSS} -horizontal_layer METAL5 -vertical_layer METAL4 -horizontal_width {10} -vertical_width {10} -horizontal_spacing {4} -vertical_spacing {4} -track_alignment track -corner_bridge true
set_pg_strategy dmem_ring_strategy_1 -macros $DATA_MEM_INST -pattern {{pattern: dmem_ring_pattern}{offset: 2}{nets: {VSS VDD}}}
compile_pg -strategies dmem_ring_strategy_1


create_pg_ring_pattern rom_ring_pattern -nets {VDD VSS} -horizontal_layer METAL5 -vertical_layer METAL4 -horizontal_width {5} -vertical_width {5} -horizontal_spacing {2} -vertical_spacing {2} -track_alignment track -corner_bridge true
set_pg_strategy rom_ring_strategy_1 -macros $ROM_INST -pattern {{pattern: rom_ring_pattern}{offset: 2}{nets: {VSS VDD}}}
compile_pg -strategies rom_ring_strategy_1

# # create_routing_blockage -zero_spacing -layers [get_layers] -boundary {{1450.0200 1975.2200} {1450.0200 2057.3600} {2050.1600 2057.3600} {2050.1600 1975.2200}}

# set_app_options -name plan.pgroute.disable_via_creation -value false
# set_app_options -name plan.pgroute.disable_stapling_via_fixing -value false

create_pg_macro_conn_pattern rom_conn \
     -pin_conn_type scattered_pin \
     -pin_layers {METAL1} \
     -layers {METAL1 METAL1}

set_pg_strategy rom_conn_str \
    -pattern { {name: rom_conn}{nets: VDD VSS}} \
    -macros $ROM_INST 

compile_pg -strategies {rom_conn_str} -ignore_via_drc



create_pg_macro_conn_pattern imem_conn \
     -pin_conn_type scattered_pin \
     -pin_layers {METAL4} \
     -layers {METAL5 METAL4}

set_pg_strategy imem_conn_str \
    -pattern { {name: imem_conn}{nets: VDD VSS}} \
    -macros $INST_MEM_INST 

compile_pg -strategies {imem_conn_str}



create_pg_macro_conn_pattern dmem_conn \
     -pin_conn_type scattered_pin \
     -pin_layers {METAL4} \
     -layers {METAL5 METAL4}

set_pg_strategy dmem_conn_str \
    -pattern { {name: dmem_conn}{nets: VDD VSS}} \
    -macros $DATA_MEM_INST 

compile_pg -strategies {dmem_conn_str}

set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_route_blockage -value {3 15 3 15}
set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_hard_macro -value {3 15 3 15}
set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_soft -value {3 15 3 15}
set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_hard -value {3 15 3 15}






create_pg_std_cell_conn_pattern PG_RAIL_CORE_METAL1_PTRN \
    -rail_width 0.3 \
    -layers METAL1

set_pg_strategy PG_RAIL_CORE_METAL1_STR -pattern {{name: PG_RAIL_CORE_METAL1_PTRN}{nets: VDD VSS}} -core -blockage {{macros_with_keepout: $ROM_INST}} -extension {{stop: outermost_ring}}


compile_pg -strategies {PG_RAIL_CORE_METAL1_STR} -tag RAIL_CORE


set_app_option -name plan.pgroute.disable_via_creation -value true


create_pg_mesh_pattern mesh_pattern \
   -layers {{{vertical_layer: METAL6} {width: 20}\
             {pitch: 100}{spacing: interleaving}}\
            {{horizontal_layer: METAL5} {width: 20}\
             {pitch: 100}{spacing: interleaving}}}

set_pg_strategy M5M6_mesh \
   -pattern {{name: mesh_pattern} \
             {nets: VSS VDD}} -core -extension {{stop: outermost_ring}}

compile_pg -strategies M5M6_mesh -ignore_via_drc


create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VSS VDD} -from_layers METAL6 -to_layers METAL5
create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VSS VDD} -from_layers METAL4 -to_layers METAL5
create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VSS VDD} -from_layers METAL4 -to_layers METAL6


set_pg_via_master_rule staple_via -contact_code {VIA12 VIA23 VIA34 VIA45 VIA56} \
         -allow_multiple {50 0} -via_array_dimension {4 1} \
         -snap_reference_point {0 0}


create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VSS VDD} -from_layers METAL1 -to_layers METAL6 -via_masters staple_via -blockage {{macros_with_keepout: all}} 


set_app_option -name plan.pgroute.disable_via_creation -value false

connect_pg_net -automatic

connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {vdd_bottom/VDD vdd_left/VDD vdd_right/VDD vdd_top/VDD}]

connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {vss_left/VSS vss_right/VSS vss_top/VSS vss_bottom/VSS}]



current_scenario func_100M.wc1p6v125c


analyze_power_plan -nets [get_nets -design [current_block] {VDD VSS}] -analyze_power -voltage 1.8





# -blockage {{macros_with_keepout: all}}
# create_pg_ring_pattern mring1_pattern -nets {VSS VDD} -horizontal_layer METAL5 -vertical_layer METAL6 -horizontal_width {5} -vertical_width {5} -horizontal_spacing {5} -vertical_spacing {5} -track_alignment track -corner_bridge true
# set_pg_strategy mring_strategy_1 -macros $ROM_INST -pattern {{pattern: mring1_pattern}{offset: 5}{nets: {VSS VDD}}}
# compile_pg -strategies mring_strategy_1
# create_pg_mesh_pattern mesh_pattern_m6 -layers { {{vertical_layer: METAL6} {width: 20} {pitch: 300} {spacing: interleaving}} }
# set_pg_strategy mesh_strategy_m6 -core -pattern {{pattern: mesh_pattern_m6}{nets: {VSS VDD}}} -extension {{stop: outermost_ring}} 
# compile_pg -strategies mesh_strategy_m6 -ignore_via_drc


# create_pg_mesh_pattern mesh_pattern_m5m6 -layers { {{horizontal_layer: METAL5} {width: 20} {pitch: 101.92} {spacing: interleaving}} }
# # set_pg_strategy mesh_strategy_m5 -core -pattern {{pattern: mesh_pattern_m5}{nets: {VSS VDD}}} -extension {{stop: outermost_ring}} 
# set_pg_strategy mesh_strategy_m5 -core -pattern {{pattern: mesh_pattern_m5}{nets: {VDD VSS}}} -extension {{stop: outermost_ring}} -blockage {{placement_blockages: all}}
# compile_pg -strategies mesh_strategy_m5 -ignore_via_drc




# connect_pg_net -automatic


# set_attribute -objects [get_cells u_rv32i_soc/data_mem_inst] -name outer_keepout_margin_hard -value {10 10 10 10}
# set_attribute -objects [get_cells u_rv32i_soc/inst_mem_inst] -name outer_keepout_margin_hard -value {10 10 10 10}

# connect_pg_net -net {VDD} [get_pins -design [current_block] -physical_context {vdd_bottom/VDD vdd_left/VDD vdd_top/VDD vdd_right/VDD}]

# connect_pg_net -net {VSS} [get_pins -design [current_block] -physical_context {vss_top/VSS vss_bottom/VSS vss_right/VSS vss_left/VSS}]


# connect_pg_net -net {VDD} [get_nets VDD_*]


# create_pg_ring_pattern ring_pattern -nets {VDD VSS} -horizontal_layer METAL5 -vertical_layer METAL6 -horizontal_width {20} -vertical_width {20} -horizontal_spacing {10} -vertical_spacing {10} -track_alignment track -corner_bridge true
# set_pg_strategy cring_strategy -core -pattern {{pattern: ring_pattern}{offset: 10}{nets: {VDD VSS}}}
# compile_pg -strategies cring_strategy


# create_pg_macro_conn_pattern ring_pin_pattern_rom -pin_conn_type ring_pin -nets {VDD VSS} -layers {METAL1 METAL2 METAL3 METAL4 METAL5 METAL6} -width {5 5} -spacing minimum -pitch {11 11} -number {100 100} -pin_layers {METAL1 METAL2}

# set_pg_strategy PG_MACRO1_METAL4_STR \
#     -pattern { {name: ring_pin_pattern_rom}{nets: VDD VSS}} \
#     -macros $ROM_INST

# compile_pg -strategies {PG_MACRO1_METAL4_STR}

# create_pg_macro_conn_pattern pads_pattern_vdd -pin_conn_type scattered_pin -layers {METAL3 METAL4} -nets {VDD} -pin_layers {METAL4}
# set_app_options -name plan.pgroute.treat_pad_as_macro -value true
# set_pg_strategy pad_conn_vdd -macros [get_cells vdd_*] -pattern {{name: pads_pattern_vdd} {nets: {VDD}}}
# compile_pg -strategies pad_conn_vdd -ignore_drc



# set_app_options -name plan.pgroute.hmpin_connection_target_layers -value {METAL6 METAL5}

# create_pg_macro_conn_pattern io_to_ring -pin_conn_type scattered_pin \
#     -pin_layers {METAL1 METAL2 METAL3} -layers {METAL5 METAL5} -width 1 \
#     -via_rule {{{intersection: all} {via_master: NIL}}}

# set_pg_strategy s_io_to_ring -macros {vss_*} \
#     -pattern {{name: io_to_ring}{nets: VSS}}

# compile_pg -strategies s_io_to_ring 


# set_app_options -name plan.pgroute.auto_connect_pg_net -value true
# set_app_options -name plan.pgroute.disable_via_creation -value true

# create_pg_macro_conn_pattern pads_pattern_vss -pin_conn_type scattered_pin -layers {METAL5 METAL6} -nets {VSS} -pin_layers {METAL1}
# set_app_options -name plan.pgroute.treat_pad_as_macro -value true
# set_pg_strategy pad_conn_vss -macros [get_cells vss_*] -pattern {{name: pads_pattern_vss} {nets: {VSS}}}
# compile_pg -strategies pad_conn_vss -ignore_drc





# create_pg_mesh_pattern mesh_pattern_m5 -layers { {{horizontal_layer: METAL5} {width: 10} {pitch: 100} {spacing: interleaving}}} 
# set_pg_strategy mesh_strategy_m5 -core -pattern {{pattern: mesh_pattern_m5}{nets: {VSS VDD}}} -extension {{stop: outermost_ring}}  
# compile_pg -strategies mesh_strategy_m5



# create_pg_mesh_pattern mesh_pattern_m6 -layers { {{vertical_layer: METAL6} {width: 10} {pitch: 100} {spacing: interleaving}} }
# set_pg_strategy mesh_strategy_m6 -core -pattern {{pattern: mesh_pattern_m6}{nets: {VSS VDD}}} -extension {{stop: outermost_ring}} 
# compile_pg -strategies mesh_strategy_m6 -ignore_via_drc


 


# create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VDD VSS} -from_layers METAL6 -to_layers METAL5



# set_pg_via_master_rule m6_m1 -contact_code {VIA12 VIA23 VIA34 VIA45 VIA56}

# create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VDD VSS} -from_layers METAL1 -to_layers METAL6 -via_masters m6_m1



# create_pg_std_cell_conn_pattern rail_pat -layers {METAL1}

# set_pg_strategy rail_strategy -core -pattern {{name: rail_pat} {nets: {VDD VSS}}}


# set_pg_via_master_rule -via_array_dimension {1 10} rail_master

# set_pg_strategy_via_rule rail_via_rule -via_rule \
#                          {{intersection: all} {via_master: rail_master}}

# compile_pg -strategies {rail_strategy} -via_rule rail_via_rule











# set_attribute -objects [get_cells u_rv32i_soc/data_mem_inst] -name outer_keepout_margin_hard -value {0 0 0 0}
# set_attribute -objects [get_cells u_rv32i_soc/inst_mem_inst] -name outer_keepout_margin_hard -value {0 0 0 0}

# set_attribute -objects [get_cells $DATA_MEM_INST] -name outer_keepout_margin_route_blockage -value {10 10 10 10}
# set_attribute -objects [get_cells $DATA_MEM_INST] -name outer_keepout_margin_hard_macro -value {10 10 10 10}
# set_attribute -objects [get_cells $DATA_MEM_INST] -name outer_keepout_margin_soft -value {10 10 10 10}
# set_attribute -objects [get_cells $DATA_MEM_INST] -name outer_keepout_margin_hard -value {10 10 10 10}

# set_attribute -objects [get_cells $INST_MEM_INST] -name outer_keepout_margin_route_blockage -value {10 10 10 10}
# set_attribute -objects [get_cells $INST_MEM_INST] -name outer_keepout_margin_hard_macro -value {10 10 10 10}
# set_attribute -objects [get_cells $INST_MEM_INST] -name outer_keepout_margin_soft -value {10 10 10 10}
# set_attribute -objects [get_cells $INST_MEM_INST] -name outer_keepout_margin_hard -value {10 10 10 10}

# set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_route_blockage -value {10 10 10 10}
# set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_hard_macro -value {10 10 10 10}
# set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_soft -value {10 10 10 10}
# set_attribute -objects [get_cells $ROM_INST] -name outer_keepout_margin_hard -value {10 10 10 10}





# create_pg_macro_conn_pattern ring_pin_pattern -pin_conn_type ring_pin -nets {VDD VSS} -pin_layers {METAL1 METAL2 METAL3 METAL4 METAL5 METAL6}


# create_pg_macro_conn_pattern ring_pin_pattern -pin_conn_type ring_pin -nets {VSS VDD} -layers {METAL4 METAL5 METAL6} -width {5 5} -spacing minimum -pitch {11 11} -number {100 100} -pin_layers {METAL4 METAL5 METAL6}

# create_pg_macro_conn_pattern PG_MACRO2_METAL3_METAL2_PTRN \
#      -pin_conn_type scattered_pin \
#      -width 1 \
#      -pin_layers {METAL3 METAL2 METAL1} \
#      -layers {METAL3 METAL2 METAL1}

# set_pg_strategy PG_MACRO1_METAL4_STR \
#     -pattern { {name: ring_pin_pattern}{nets: VDD VSS}} \
#     -macros {*/tsmc_rom_inst}

# compile_pg -strategies {PG_MACRO1_METAL4_STR}

# create_pg_vias -within_bbox {{1445.0200 1969.2200} {1445.0200 2093.2800} {2096.0800 2093.2800} {2096.0800 1969.2200}} -nets {VDD} -start {{5 5}} -pitch {{10 10}}


# create_pg_vias \
#              -within_bbox {{1445.0200 1969.2200} {1445.0200 2093.2800} {2096.0800 2093.2800} {2096.0800 1969.2200}} \
#              -nets {VDD} \
#              -from_layers METAL6 \
#              -to_layers METAL1 \
#              -drc no_check \
#              -insert_additional_vias


# create_pg_vias \
#              -within_bbox {{1445.0200 1969.2200} {1445.0200 2093.2800} {2096.0800 2093.2800} {2096.0800 1969.2200}} \
#              -nets {VSS} \
#              -from_layers METAL6 \
#              -to_layers METAL2 \
#              -drc no_check \
#              -insert_additional_vias







# set errdm [open_drc_error_data "DRC_report_by_check_pg_drc"]
# set errs [get_drc_errors -error_data $errdm]
# fix_pg_missing_vias -error_data $errdm $errs


# connect_pg_net -automatic
# analyze_power_plan -nets {VDD} -power_budget 40.000

###analyze_pg_ir_drop

