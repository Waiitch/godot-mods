extends Node

class_name go



func _ready() -> void:
	
	Logger.write("getin")
	_connect_to_root()
	set_process_unhandled_input(true)
	action()

	
func deferred_add_to_root(root: Node)->void:
	
	# 确保不在场景树中
	print("正在连接至",root.name)
	if is_inside_tree():
		get_parent().remove_child(self)
	# 添加节点
	root.add_child(self)
	self.owner=root
	# 再次验证
	if is_inside_tree():
		print("延迟添加成功: ", get_path())
	else:
		push_error("延迟添加失败")
		
func _unhandled_input(_event: InputEvent)->void :
	
	if Input.is_action_just_pressed("language"):
		Logger.write("click")
		change_lan()
			
func action() -> void:
	
	var action_name:String = "language"
	Logger.write("getlang")
	# 2. 如果动作不存在则创建
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	# 3. 清除旧绑定（可选，重置时使用）
	InputMap.action_erase_events(action_name)
	
	# 4. 创建新输入事件
	var jump_key:InputEvent = InputEventKey.new()
	jump_key.keycode = KEY_T
	
	# 5. 添加事件到动作
	InputMap.action_add_event(action_name, jump_key)
	
func change_lan() -> void:
	
	const SETTINGS_SECTION = SettingsManager.Keys.SECTION_GENERAL
	const SETTINGS_KEY = SettingsManager.Keys.SETTING_LANGUAGE
	var current_locale: = TranslationServer.get_locale()
	if current_locale=="en":
		var locale: String = "zh_TW"
		TranslationServer.set_locale(locale)
		SettingsManager.set_setting(
			SETTINGS_SECTION, 
			SETTINGS_KEY, 
			locale
		)
	else:
		var locale: String = "en"
		TranslationServer.set_locale(locale)
		SettingsManager.set_setting(
			SETTINGS_SECTION, 
			SETTINGS_KEY, 
			locale
		)

func _notification(what: int)->void:
	#print(what)
	if what == NOTIFICATION_PREDELETE:
		Logger.write("Persistent node is being deleted.")
	elif what == NOTIFICATION_UNPARENTED:
		Logger.write("Node unparented. Attempting to reconnect...")
		var mod:Variant=mod.new()
		
		
func _connect_to_root()->void:
	
	if not is_inside_tree():
		# 获取当前场景树根节点
		var main_loop:Variant =Engine.get_main_loop()
	
	# 验证是否是 SceneTree
		if main_loop is SceneTree:
			var root:Variant = main_loop.root
			#main_loop.process_frame.connect(deferred_add_to_root.bind(root), CONNECT_ONE_SHOT)
			call_deferred("deferred_add_to_root", root)
			print("已连接到根节点：", get_path())
