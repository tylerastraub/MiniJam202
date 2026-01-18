extends Node3D

class_name Enemy

var _textures : Array[Texture2D] = []
var tex1 : Texture2D = preload("res://res/textures/t_enemy1.png")
var tex2 : Texture2D = preload("res://res/textures/t_enemy2.png")
var tex3 : Texture2D = preload("res://res/textures/t_enemy3.png")
var tex4 : Texture2D = preload("res://res/textures/t_enemy4.png")
var tex5 : Texture2D = preload("res://res/textures/t_enemy5.png")
var tex6 : Texture2D = preload("res://res/textures/t_enemy6.png")
var tex7 : Texture2D = preload("res://res/textures/t_enemy7.png")
var tex8 : Texture2D = preload("res://res/textures/t_enemy8.png")

var _shake : ShakeEffect

var _ai : DuelAI

@onready var _animation : AnimationTree = $AnimationTree

var _hurt_counter : float = 0.0
var _hurt_time : float = 0.75

var _starting_x : float = 0.0

func _init() -> void:
    _shake = ShakeEffect.new()
    _shake.shake_decrement = 1.0 / _hurt_time
    _ai = DuelAI.new()

func _ready() -> void:
    rotation.y = deg_to_rad(90.0)
    load_textures()
    var mat : StandardMaterial3D = $SamuraiMesh/Armature/Skeleton3D/samurai.get_surface_override_material(0).duplicate()
    mat.albedo_texture = _textures[randi() % _textures.size()]
    $SamuraiMesh/Armature/Skeleton3D/samurai.set_surface_override_material(0, mat)

func ai_init(stats: DuelStats) -> void:
    _ai.ai_init(stats)

func _physics_process(delta: float) -> void:
    var coefficient : float = 1.0 if randi() % 2 else -1.0
    position.x = _starting_x + _shake.max_shake * _shake.shake_amount * coefficient
    _shake.update_shake(delta)
    
    if get_state() == DuelAI.State.HURT:
        _hurt_counter += delta
        if _hurt_counter > _hurt_time:
            if _ai._stats.health < 1:
                set_state(DuelAI.State.DEAD)
            else:
                set_state(DuelAI.State.READY)
    
    animate(delta)
    update_sword_meshes()

# returns true if action ready to be taken for this turn
func action(timer: float) -> bool:
    return _ai.action(timer)

# returns Attack struct containing attack stats
func attack() -> Attack:
    return _ai.attack()

# returns true if successfully defended
func defend() -> bool:
    return _ai.defend()

# if critical == true, one shot kills no matter what
func strike(critical: bool) -> void:
    print("ow i've been struck! i am " + str(self) + ", critical: " + str(critical))
    _shake.shake_amount = 1.0
    _ai.strike(critical)

func set_state(state: DuelAI.State) -> void:
    _ai.set_state(state)

func get_stats() -> DuelStats:
    return _ai._stats

func get_state() -> DuelAI.State:
    return _ai._state

func get_last_state() -> DuelAI.State:
    return _ai._last_state

func animate(_delta: float) -> void:
    _animation.set("parameters/conditions/draw", get_state() == DuelAI.State.DRAW)
    _animation.set("parameters/conditions/hurt", get_state() == DuelAI.State.HURT)
    _animation.set("parameters/conditions/fall", get_state() == DuelAI.State.DEAD)
    _animation.set("parameters/conditions/sheath", get_state() == DuelAI.State.SHEATH)

func update_sword_meshes() -> void:
    if get_state() == DuelAI.State.READY:
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = true
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = false
    elif get_state() == DuelAI.State.DRAW:
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = true
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = true
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = false
    elif get_state() == DuelAI.State.SHEATH:
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = true
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = true
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = false
    elif get_state() == DuelAI.State.HURT:
        if get_last_state() == DuelAI.State.READY:
            $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = false
            $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = false
            $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = false
            $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = true
        elif get_last_state() == DuelAI.State.DRAW:
            $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = true
            $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = false
            $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = true
            $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = false
    elif get_state() == DuelAI.State.DEAD:
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword2.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HandAttachment/sword_sheathed.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sheath2.visible = false
        $SamuraiMesh/Armature/Skeleton3D/HipAttachment/sword_sheathed.visible = true

func load_textures() -> void:
    _textures.push_back(tex1)
    _textures.push_back(tex2)
    _textures.push_back(tex3)
    _textures.push_back(tex4)
    _textures.push_back(tex5)
    _textures.push_back(tex6)
    _textures.push_back(tex7)
    _textures.push_back(tex8)
