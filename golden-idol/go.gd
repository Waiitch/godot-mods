extends Node

class_name go

const BASE_DIR_PATH: String = "user://mods/1/"

var key: int
var lang_1 : String
var lang_2 : String
var result = []

func _ready()->void :
	
	Logger.write("getin")
	var cfg_file: FileAccess = FileAccess.open("%sconfig.txt" % BASE_DIR_PATH, FileAccess.READ)
	key=cfg_file.get_line().unicode_at(0)
	Logger.write("%s"%key)
	lang_1=cfg_file.get_line()
	Logger.write(lang_1)
	lang_2=cfg_file.get_line()
	Logger.write(lang_2)
	if key == 0:
		key = 84
	if lang_1.is_empty():
		lang_1 = 'en'
	if lang_2.is_empty():
		lang_2 = 'zh_TW'
		
	_connect_to_root()
	set_process_unhandled_input(true)
	action()


func deferred_add_to_root(root: Node)->void :


	print("正在连接至", root.name)
	if is_inside_tree():
		get_parent().remove_child(self)

	root.add_child(self)
	self.owner = root

	if is_inside_tree():
		print("延迟添加成功: ", get_path())
	else:
		push_error("延迟添加失败")

func _unhandled_input(_event: InputEvent)->void :

	if Input.is_action_just_pressed("language"):
		Logger.write("click")
		change_lan()

func action()->void :
	
	
	
	var action_name: String = "language"
	Logger.write("getlang")

	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)


	InputMap.action_erase_events(action_name)

	
	var jump_key: InputEvent = InputEventKey.new()
	
	jump_key.keycode = key


	InputMap.action_add_event(action_name, jump_key)


func get_all_phrases() -> void:
	result.clear()
	var root = get_tree().root    
	traverse_node(root)

func traverse_node(node: Node) -> void:
	#Logger.write("finding")
	if node is Phrase:
		#Logger.write("found")
		result.append(node)
	for child in node.get_children():
		traverse_node(child)

func change_lan()->void :

	const SETTINGS_SECTION = SettingsManager.Keys.SECTION_GENERAL
	const SETTINGS_KEY = SettingsManager.Keys.SETTING_LANGUAGE
	var current_locale = TranslationServer.get_locale()


	
	if current_locale == lang_1:
		var locale: String = lang_2
		TranslationServer.set_locale(locale)
		SettingsManager.set_setting(
			SETTINGS_SECTION, 
			SETTINGS_KEY, 
			locale
		)
	else:
		var locale: String = lang_1
		TranslationServer.set_locale(locale)
		SettingsManager.set_setting(
			SETTINGS_SECTION, 
			SETTINGS_KEY, 
			locale
		)
	Logger.write("flag1")
	get_all_phrases()
	var res:String = str(result.size())
	for child in result:
		var slotted_item_id = child.id
		var item: GIItem = Database.get_item_by_id(slotted_item_id)
		child.set_data_from_item(item)
		#Logger.write("changed")
	Logger.write(res)

func _notification(what: int)->void :

	if what == NOTIFICATION_PREDELETE:
		Logger.write("Persistent node is being deleted.")
	elif what == NOTIFICATION_UNPARENTED:
		Logger.write("Node unparented. Attempting to reconnect...")
		var mod: Variant = mod.new()


func _connect_to_root()->void :

	if not is_inside_tree():

		var main_loop: Variant = Engine.get_main_loop()


		if main_loop is SceneTree:
			var root: Variant = main_loop.root

			call_deferred("deferred_add_to_root", root)
			print("已连接到根节点：", get_path())
