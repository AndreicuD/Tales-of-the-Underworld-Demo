extends Area2D

var active : bool = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if active:
			$AudioStreamPlayer.play()
			Global.CURRENT_LEVEL_CURRENCY += 1
		active = false
		$CoinSprite.visible = false

func _on_audio_stream_player_finished():
	queue_free()
