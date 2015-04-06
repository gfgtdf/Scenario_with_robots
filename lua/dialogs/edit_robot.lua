local T = helper.set_wml_tag_metatable {}

function create_dialog_grid(size_x, size_y)
	local grid = T.grid {} 
	local cells = {}
	for iY = 1 , size_y do
		cells[iY] = cells[iY] or {}
		local row_content = {}
		table.insert(grid[2], T.row(row_content) )
		for iX = 1 , size_x do
			local cell_content = {}
			cells[iY][iX] = cell_content
			table.insert(row_content, T.column(cell_content) )
		end
	end
	return {
		get_cell = function(x, y) return cells[y][x] end,
		get_grid = function() return grid end,
	}
end

function create_edit_robot_dialog(grid_field, grid_toolbox)
	return {
		T.tooltip {
			id = "tooltip_large",
		},
		T.helptip {
			id = "tooltip_large",
		},
		T.grid { 
			T.row {
				T.column {
					T.grid { 
						T.row {
							T.column {
								T.label {
									definition = "title",
									label = "Edit Robot",
								},
							},
						}, 
						T.row {
							T.column {
								grid_field,
							},
						},
						T.row {
							T.column {
								T.label {
									definition = "title",
									label = "Toolbox",
								},
							},
						}, 
						T.row {
							T.column {
								grid_toolbox,
							},
						},
					},
				},
				T.column {
					vertical_grow = true,
					T.grid {
						T.row {
							T.column {
								vertical_alignment = "top",
								border = "all",
								border_size = 5,
								T.grid {
									T.row {
										T.column {
											border = "all",
											border_size = 5,
											T.label {
												-- definition = "title",
												label = "Selected item",
											},
										},
									}, 
									T.row {
										T.column {
											T.image {
												id = "image_selected_item",
											},	
										},
									},
								},
							},
						}, 
						T.row {
							T.column {
								vertical_alignment = "bottom",
								T.grid {
									T.row {
										T.column {
											T.button {
												id = "ok" ,
												label = "OK",
											},	
										},
									},
								},
							},
						}, 
					},
				},
			},
		},
	}
end

function create_tooltip_field(index_str, tooltip_str)
	return T.toggle_panel {
		id = "down_panel" .. index_str,
		T.grid { 
			T.row {
				vertical_grow = true,
				T.column {
					T.image {
						id = "down_icon" .. index_str,
						tooltip = tooltip_str
					},
				},
			},
			T.row {
				vertical_grow = true,
				T.column {
					T.label {
						id = "down_label" .. index_str
					},
				},
			},
		},
	}
end

function create_unused_tooltip_field(imagename)
	return T.toggle_panel {
		T.grid {
			T.row {
				vertical_grow = true, 
				T.column {
					T.image {
						label = imagename,
					},
				},
			},
		},
	} 
end

function create_robot_field(index_str)
	return  T.toggle_panel {
		id = "cell_panel" .. index_str,
		T.grid {
			T.row {
				vertical_grow = true, 
				T.column {
					T.image {
						id = "cell_icon"  .. index_str
					},
				},
			},
		},
	}
end
