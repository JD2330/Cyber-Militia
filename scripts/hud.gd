extends CanvasLayer

@onready var health_bar = $VBoxContainer/HealthBar
@onready var fuel_bar = $VBoxContainer/FuelBar

# Called by the player to update values
func update_health(value: float):
	health_bar.value = clamp(value, 0, 100)

func update_fuel(percent: float):
	fuel_bar.value = clamp(percent * 100, 0, 100)
