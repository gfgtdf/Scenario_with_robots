-- this was made from the inventory by vultraz
-- i still dont know how to get vertical/horizontal aligmnet working :/
local buttons = {
	ok = 1,
	abort = 2
}


local item_list = T.listbox {
	id = "trader_list",
	vertical_scrollbar_mode = "always",
	T.list_definition {
		T.row {
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.toggle_panel {
					T.grid {
						T.row {
							grow_factor = 1,
							T.column {
								grow_factor = 1,
								border = "all",
								border_size = 5,
								horizontal_grow = true,
								T.image {
									id = "list_image",
									linked_group = "image"
								}
							},
							T.column {
								grow_factor = 1,
								border = "all",
								border_size = 5,
								horizontal_grow = true,
								T.label {
									id = "list_name",
									linked_group = "name"
								}
							},
							T.column {
								grow_factor = 1,
								border = "all",
								border_size = 5,
								horizontal_alignment = "center",
								T.label {
									id = "list_quantity",
									linked_group = "quantity"
								}
							},
							T.column {
								grow_factor = 1,
								border = "all",
								border_size = 5,
								horizontal_alignment = "center",
								T.label {
									id = "list_basket",
									linked_group = "l_basket"
								}
							},
							T.column {
								grow_factor = 1,
								border = "all",
								border_size = 5,
								horizontal_alignment = "center",
								T.label {
									id = "list_price",
									linked_group = "l_price"
								}
							},
						}
					}
				}
			}
		}
	}
}

local details_panel_pages = T.multi_page {
	id = "details_pages",
	T.page_definition {
		T.row {
			grow_factor = 1,
			T.column {
				grow_factor = 1,
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "top",
				T.label {
					definition = "title",
					id = "details_name"
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				grow_factor = 1,
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "top",
				T.scroll_label {
					id = "details_description",
					linked_group = "d_desc",
					wrap = true
				}
			}
		},
		T.row {
			--vertical_alignment = "bottom",
			grow_factor = 1,
			T.column {
				
				--vertical_alignment = "bottom",
				T.grid {
				
					--vertical_alignment = "bottom",
					T.row {
					
						--vertical_alignment = "bottom",
						T.column {
							vertical_alignment = "bottom",
							border = "left, right, top" ,
							border_size = 10,
							T.label {
							--vertical_alignment = "bottom",
								id = "details_quantity",
								label = _ "                  "
							}
						},
						T.column {
							--vertical_alignment = "bottom",
							border =  "left, right, top" ,
							border_size = 10,
							T.label {
							--vertical_alignment = "bottom",
								id = "details_basket_count",
								label = _ "in your basket: 0   "
							}
						},
						T.column {
							--vertical_alignment = "bottom",
							border = "left, right, top",
							border_size = 10,
							T.label {
								vertical_alignment = "bottom",
								id = "details_price",
								label = _ "Price: 0g   "
							}
						},
					}
				}
			}
		}
	}
}

local main_window = {
	maximum_height = 700,
	maximum_width = 850,

	T.helptip { id = "tooltip_large" }, -- mandatory field
	T.tooltip { id = "tooltip_large" }, -- mandatory field

	T.linked_group { id = "image", fixed_width = true, fixed_height = true },
	T.linked_group { id = "name", fixed_width = true },
	T.linked_group { id = "quantity", fixed_width = true },
	T.linked_group { id = "l_basket", fixed_width = true },
	T.linked_group { id = "l_price", fixed_width = true },
	T.linked_group { id = "l_b_number", fixed_width = true },
	T.linked_group { id = "d_desc", fixed_height = true },

	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				grow_factor = 1,
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				T.label {
					definition = "title",
					label = _"Shop"
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_grow = true,
				vertical_grow = true,
				T.grid {
					T.row {
						T.column {
							grow_factor = 1,
							border = "all",
							border_size = 5,
							horizontal_grow = true,
							vertical_grow = true,
							item_list
						},
						T.column {
							grow_factor = 1,
							border = "all",
							border_size = 5,
							horizontal_grow = true,
							vertical_grow = true,
							T.label {
								label = _ "  "
							}
						}
					},
					T.row {
						
						maximum_height = 50,
						grow_factor = 1,
						T.column {
							
						maximum_height = 50,
							grow_factor = 1,
							horizontal_grow = true,
							vertical_alignment = "top",
							details_panel_pages
						},
						T.column {
							grow_factor = 1,
							horizontal_alignment = "right",
							T.grid {
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										T.label {
											id = "total_price_label",
											label = _"Total: 0g"
										}
									}
								},
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										T.button {
											id = "order_button",
											label = _"Buy Item"
										}
									}
								},
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										T.button {
											id = "remove_button",
											label = _"Remove Item"
										}
									}
								},
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										T.button {
											id = "use_button",
											return_value = buttons.ok,
											label = _"Purchase"
										}
									}
								},
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										T.button {
											id = "ok_button",
											return_value = buttons.abort,
											label = _"Abort"
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return {
	buttons = buttons;
	normal = main_window;
}
