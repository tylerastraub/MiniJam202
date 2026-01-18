extends Node3D

class_name Player

var _shake : ShakeEffect

var _ai : DuelAI

@onready var _animation : AnimationTree = $AnimationTree

var _hurt_counter : float = 0.0
var _hurt_time : float = 0.5

func _init() -> void:
    _shake = ShakeEffect.new()
    _ai = DuelAI.new()
    var stats : DuelStats = DuelStats.new()
    _ai.ai_init(stats)

func _physics_process(delta: float) -> void:
    var coefficient : float = 1.0 if randi() % 2 else -1.0
    position.x = -2.5 + _shake.max_shake * _shake.shake_amount * coefficient
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
