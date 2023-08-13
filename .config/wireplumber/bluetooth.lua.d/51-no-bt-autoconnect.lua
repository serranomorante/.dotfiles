---@diagnostic disable: undefined-global
table.insert(bluez_monitor.rules, {
	matches = { { { "device.name", "matches", "bluez_card.*" } } },
	apply_properties = { ["bluez5.auto-connect"] = "[ ]" },
})
