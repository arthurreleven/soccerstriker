extends Control

@onready var tex = $TextureRect

func _ready():
	if not OS.has_feature("editor"):
		if not OS.has_feature("permission:CAMERA"):
			OS.request_permissions()
			await get_tree().create_timer(3.0).timeout
	iniciar_camera()

func iniciar_camera():
	CameraServer.set_monitoring_feeds(true)
	await get_tree().create_timer(2.0).timeout
	
	var feeds = CameraServer.feeds()
	if feeds.size() == 0:
		print("ERRO: Nenhum feed encontrado")
		return
	
	var feed_escolhido = null
	for feed in feeds:
		if feed.get_position() == CameraFeed.FeedPosition.FEED_BACK:
			feed_escolhido = feed
			break
	if feed_escolhido == null:
		feed_escolhido = feeds[0]
	
	feed_escolhido.set_format(8, {})
	feed_escolhido.set_active(true)
	await get_tree().create_timer(0.5).timeout
	
	var cam_tex_y = CameraTexture.new()
	cam_tex_y.camera_feed_id = feed_escolhido.get_id()
	cam_tex_y.which_feed = 0
	
	var cam_tex_cbcr = CameraTexture.new()
	cam_tex_cbcr.camera_feed_id = feed_escolhido.get_id()
	cam_tex_cbcr.which_feed = 1
	
	tex.texture = cam_tex_y
	tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	var mat = tex.material as ShaderMaterial
	mat.set_shader_parameter("texture_cbcr", cam_tex_cbcr)
