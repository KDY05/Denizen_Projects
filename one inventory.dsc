# 인벤토리 한 칸 스크립트
# 사용 방법: /oneinv on|off (서버에 접속한 모든 플레이어에게 적용됩니다.)
# Script written by 어라랍(https://github.com/KDY05)

oneinv_init:
    type: world
    events:
        on scripts loaded:
        - if !<server.has_flag[one_inv]>:
            - flag server one_inv:false

oneinv_command:
    type: command
    name: oneinv
    description: 인벤토리 한 칸 모드 커맨드
    usage: /oneinv on|off
    tab completions:
        1: on|off
    script:
    - if <context.args.is_empty>:
        - narrate "<&e>/oneinv on|off" targets:<player>
        - stop
    - choose <context.args.first>:
        - case on:
            - if <server.flag[one_inv]>:
                - narrate "<&e>이미 활성화되었습니다." targets:<player>
                - stop
            - flag server one_inv:true
            - reload scripts_now
            - foreach <server.online_players> as:players:
                - run fill_slot_task def.target:<[players]>
                - narrate "<&a>인벤토리 한 칸 모드가 활성화되었습니다." targets:<[players]>
            - stop
        - case off:
            - if !<server.flag[one_inv]>:
                - narrate "<&e>이미 비활성화되었습니다." targets:<player>
                - stop
            - flag server one_inv:false
            - reload scripts_now
            - foreach <server.online_players> as:players:
                - repeat 36 as:count:
                    - if <[count]> != 5:
                        - inventory set d:<[players].inventory> slot:<[count]> o:air
                - narrate "<&c>인벤토리 한 칸 모드가 비활성화되었습니다." targets:<[players]>
            - stop
        - default:
            - narrate "<&e>/oneinv on|off" targets:<player>

oneinv_world:
    type: world
    enabled: <server.flag[one_inv]>
    events:
        on player dies:
        - define saved <player.inventory.slot[5]>
        - drop <[saved]> <player.location>
        - foreach <player.equipment> as:equip:
            - drop <[equip]> <player.location>
        - determine NO_DROPS
        after player dies:
        - run fill_slot_task def.target:<player>
        on player swaps items:
        - determine cancelled
        on player drops empty_slot:
        - determine cancelled
        on player clicks empty_slot in inventory:
        - determine cancelled
        on player drags empty_slot in inventory:
        - determine cancelled
        on player places empty_slot:
        - determine cancelled

fill_slot_task:
    type: task
    definitions: target
    script:
    - repeat 36 as:count:
        - if <[count]> != 5:
            - define saved <[target].inventory.slot[<[count]>]>
            - drop <[saved]> <[target].location>
            - inventory set d:<[target].inventory> slot:<[count]> o:empty_slot
    - drop <[target].item_in_offhand> <[target].location>
    - adjust <[target]> item_in_offhand:air

empty_slot:
    type: item
    material: light_gray_stained_glass_pane
    display name: ' '