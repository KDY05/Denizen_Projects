# 좀비화 스크립트 (v1.1)
# 사용 방법: /zombie on|off (서버에 접속한 모든 플레이어에게 적용됩니다.)
# 기능: 좀비 기본 스펙 적용(공격력 3, 방어력 2), 햇빛에 탐, 체력 자연 재생 불가, 사망 시 보유 아이템 대신 썩은고기 드랍, 주민 강제 타격, 철골렘 적대
# Script written by 어라랍(https://github.com/KDY05)

zombie_init:
    type: world
    events:
        on scripts loaded:
        - if !<server.has_flag[zombie]>:
            - flag server zombie:false

zombie_world:
    type: world
    enabled: <server.flag[zombie]>
    events:
        on delta time secondly:
        - foreach <server.online_players> as:origin:
            # 햇빛에 탐
            - if <[origin].location.world.is_day>:
                - if ( <[origin].location.highest.y> <= <[origin].location.y.sub[1]> ) && ( !<[origin].has_equipped[*_helmet]> ):
                    - burn <[origin]> duration:8
                    - actionbar "<&e>볕이 너무 뜨겁다!" targets:<[origin]>
            # 주민 강제 타격
            - define vil <[origin].eye_location.ray_trace_target[range=4.0;entities=villager;raysize=1.0]||null>
            - if <[vil]> != null:
                - hurt 3 <[vil]> cause:ENTITY_ATTACK source:<[origin]>
                - playsound <[origin].location> sound:ENTITY_ZOMBIE_AMBIENT volume:1.0 pitch:1.0
                - actionbar "<&e>좀비의 본능으로 어쩔 수 없이 주민을 때리고 말았다." targets:<[origin]>
            # 철골렘 적대
            - foreach <[origin].location.find_entities[iron_golem].within[15]> as:golem:
                - attack <[golem]> target:<[origin]>
        on player kills villager:
        # 주민 좀비화(+ 직업, 나이 구현)
        - flag server prof:<context.entity.profession>
        - if <context.entity.is_baby>:
            - flag server age:baby
        - else:
            - flag server age:adult
        - define rand <util.random.int[1].to[2]>
        - if <[rand]> == 1:
            - spawn zombie_vil_with_prof <context.entity.location> persistent
        on player heals:
        # 체력 자연 재생 불가
        - if <context.reason> == SATIATED || <context.reason> == EATING:
            - actionbar "<&e>몬스터는 체력이 재생되지 않는다." targets:<player>
            - determine cancelled
        on player dies:
        # 사망 시 보유 아이템 대신 썩은고기 드랍
        - define rand <util.random.int[1].to[3]>
        - drop rotten_flesh <player.location> quantity:<[rand]>
        - playsound <player.location> sound:ENTITY_ZOMBIE_DEATH volume:1.0 pitch:1.0
        - determine NO_DROPS
        on player damaged:
        - playsound <player.location> sound:ENTITY_ZOMBIE_HURT volume:1.0 pitch:1.0
        on player damages entity:
        - playsound <player.location> sound:ENTITY_ZOMBIE_AMBIENT volume:0.5 pitch:1.0
        - actionbar "<&e>좀비의 완력으로 더 강하게 타격했다." targets:<player>

# 좀비 기본 스펙 적용(공격력 3, 방어력 2)
zombie_mech:
    type: task
    definitions: toggle
    script:
    - if <[toggle]> == on:
        - foreach <server.online_players> as:origin:
            - definemap spec:
                generic_attack_damage: 3.0
                generic_armor: 2.0
            - adjust <[origin]> attribute_base_values:<[spec]>
    - else:
        - foreach <server.online_players> as:origin:
            - definemap spec:
                generic_attack_damage: 1.0
                generic_armor: 0.0
            - adjust <[origin]> attribute_base_values:<[spec]>

zombie_vil_with_prof:
    type: entity
    entity_type: zombie_villager
    mechanisms:
        profession: <server.flag[prof]>
        age: <server.flag[age]>

zombie_command:
    type: command
    name: zombie
    description: zombie command
    usage: /zombie on|off
    tab completions:
        1: on|off
    script:
    - if <context.args.is_empty>:
            - narrate "<&e>/zombie on|off" targets:<player>
            - stop
    - else:
        - choose <context.args.first>:
            - case on:
                - flag server zombie:true
                - reload scripts_now
                - run zombie_mech def.toggle:on
                - narrate "<&2>좀비화를 활성화합니다." targets:<server.online_players>
                - stop
            - case off:
                - flag server zombie:false
                - reload scripts_now
                - run zombie_mech def.toggle:off
                - narrate "<&c>좀비화를 비활성화합니다." targets:<server.online_players>
                - stop
            - default:
                - narrate "<&e>/zombie on|off" targets:<player>