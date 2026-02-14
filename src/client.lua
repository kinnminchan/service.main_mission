local playerMission = false

local playerCurrentBlips
local playerCurrentProducts = {}

local missionDesign = [[
    .div_mission {
        position: absolute;
        font-size: 13px;
        bottom: 40px;
        left: 320px;
        color: white;
        background: rgba(0, 0, 0, 0.4);
        box-shadow: 0 0 3px 0 rgba(0, 0, 0, 0.8);
        min-width: 320px;
        max-width: 500px;
        padding-bottom: 10px;
        font-family: 'NanumSquareNeo', sans-serif;
        font-weight: 700;
    }

    .div_mission .name {
        background: rgba(0, 0, 0, 0.3);
        padding: 9px;
        font-family: 'NanumSquareNeo', sans-serif;
        color: rgb(255, 255, 255);
        font-weight: 700;
    }

    .div_mission .step {
        position: absolute;
        right: 8px;
        top: 9px;
        color: rgb(255, 255, 255);
        font-weight: 700;
        font-family: 'NanumSquareNeo', sans-serif;
    }

    .div_mission .sda {
        position: relative;
        margin-top: 10px;
        color: rgb(207, 207, 207);
        font-weight: 700;
        padding-right: 15px;
        padding-left: 15px;
        font-family: 'NanumSquareNeo', sans-serif;
    }

    .div_mission .list {
        position: relative;
        color: rgb(255, 255, 255);
        font-weight: 700;
        margin-left: 15px;
        font-family: 'NanumSquareNeo', sans-serif;
    }
]]

local SetDiv = function (name, css, content)
    SendNUIMessage({
        action = "set_div",
        name = name,
        css = css,
        content = content
    })
end

local SetDivContent = function (name, content)
    SendNUIMessage({
        action = "set_div_content",
        name = name,
        content = content
    })
end

local RemoveDiv = function (name)
    SendNUIMessage({
        action = "remove_div",
        name = name
    })
end

GenerateBlips = function (mission, position)
    local missionBlips = AddBlipForCoord(position.x, position.y, position.z)

    -- 모양 설정
    SetBlipSprite(missionBlips, mission.blips.icon)
    SetBlipColour(missionBlips, mission.blips.color)
    SetBlipDisplay(missionBlips, 4)
    SetBlipScale(missionBlips, 1.0)
    SetBlipAsShortRange(missionBlips, false)

    -- 이름 설정
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('[배달 미션] ' .. mission.name)
    EndTextCommandSetBlipName(missionBlips)

    -- 경로 설정
    SetBlipRoute(missionBlips, true)
    SetBlipRouteColour(missionBlips, mission.blips.color)

    playerCurrentBlips = missionBlips -- 플레이어 빌립스 데이터를 저장합니다.
end

GenerateMissionArea = function (mission, position)
    CreateThread(function ()
        while playerMission do
            local waitTime = 500

            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)

            local distance = #(playerCoords - position)

            if distance < 40 then
                waitTime = 0 -- 스레드 주기를 변경합니다.
                ---@diagnostic disable-next-line: param-type-mismatch
                DrawMarker(1, position.x, position.y, position.z -1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 255, 103, 179, 125, false, true, 2, false, nil, nil, false)

                if distance < 1.5 and IsControlJustPressed(0, 38) then
                    TriggerServerEvent('server/main/mission:CompleteMission', mission, json.encode(playerCurrentProducts))
                end
            end

            Wait(waitTime)
        end
    end)
end

StartMission = function (mission, missionLevel)
    local randomIndex = math.random(1, #mission.positions[missionLevel])
    local randomPosition = mission.positions[missionLevel][randomIndex]

    playerMission = true

    GenerateBlips(mission, randomPosition)
    GenerateMissionArea(mission, randomPosition)

    for _, product in ipairs(mission.products[missionLevel]) do
        local randomAmount = math.random(product.amount[1], product.amount[2])

        table.insert(playerCurrentProducts, {
            name = product.name,
            item = product.item,
            price = product.price,
            amount = randomAmount
        })
    end

    local playerProductList = {}

    for _, product in ipairs(playerCurrentProducts) do
        table.insert(playerProductList, string.format("- %s (%d개)", product.name, product.amount))
    end

    local playerProductListToString = table.concat(playerProductList, "<br>") -- 줄바꿈을 위해 HTML 태그를 추가합니다.

    SetDiv('mission', missionDesign, '')
    SetDivContent('mission', string.format([[
        <div class='div_mission'>
            <div class='name'>HYBE MISSION</div>
            <div class='step'>0/1</div>
            <div class='sda'>아이템을 지정된 곳에 배달하세요!</div>
            <div class='list'>%s</div>
        </div>
    ]], playerProductListToString))
end

RegisterNetEvent('client/main/mission:StartMission', function (mission, missionLevel)
    StartMission(mission, missionLevel)
end)

local StopMission = function ()
    if not playerMission then
        return
    end

    playerMission = false -- 미션 구역을 제거합니다.
    RemoveBlip(playerCurrentBlips); playerCurrentBlips = nil -- 미션 빌립스를 제거합니다.
    playerCurrentProducts = {} -- 미션 아이템 목록을 초기화합니다.

    RemoveDiv('mission')
end

RegisterNetEvent('client/main/mission:StopMission', function ()
    StopMission()
end)