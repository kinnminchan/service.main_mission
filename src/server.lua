OxMySQL = exports['oxmysql']

local CONFIG_MISSIONS <const> = Missions

local FormatComma = function (amount)
	local formatted = amount

	while true do
	    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	    if ( k == 0 ) then
		    break
	    end
	end

	return formatted
end

local GetMaxLevel = function (missionLevel)
    local levelData = {}

    for level, _ in pairs(missionLevel) do
        table.insert(levelData, level)
    end

    table.sort(levelData)

    return levelData[#levelData] -- 마지막 키를 최댓값으로 반환합니다.
end

GetLevel = function (source, mission)
    local citizenId = exports['service.base_framework']:GetCitizenId(source)

    local result = OxMySQL:executeSync("SELECT level FROM mission WHERE id = @id AND mission = @mission", {
        ['@id'] = citizenId,
        ['@mission'] = mission.name
    })

    local missionMaxLevel = GetMaxLevel(mission.levels)

    if not result or #result == 0 then
        if missionMaxLevel == 0 then
            OxMySQL:executeSync("INSERT INTO mission (id, mission, level, exp) VALUES (@id, @mission, @level, @exp)", {
                ['@id'] = citizenId,
                ['@mission'] = mission.name,
                ['@level'] = missionMaxLevel,
                ['@exp'] = 0,
            })

            return 0 -- 미션 레벨이 없을 경우, 초기값인 0레벨을 반환합니다.
        else
            OxMySQL:executeSync("INSERT INTO mission (id, mission, level, exp) VALUES (@id, @mission, @level, @exp)", {
                ['@id'] = citizenId,
                ['@mission'] = mission.name,
                ['@level'] = 1,
                ['@exp'] = mission.levels[1].minEXP,
            })

            return 1 -- 미션 레벨이 없을 경우, 초기값인 1레벨을 반환합니다.
        end
    else
        local currentLevel = result[1].level
        return currentLevel
    end
end

GetEXP = function (source, mission)
    local citizenId = exports['service.base_framework']:GetCitizenId(source)

    local result = OxMySQL:executeSync("SELECT exp FROM mission WHERE id = @id AND mission = @mission", {
        ['@id'] = citizenId,
        ['@mission'] = mission.name
    })

    local missionMaxLevel = GetMaxLevel(mission.levels)

    if not result or #result == 0 then
        if missionMaxLevel == 0 then
            OxMySQL:executeSync("INSERT INTO mission (id, mission, level, exp) VALUES (@id, @mission, @level, @exp)", {
                ['@id'] = citizenId,
                ['@mission'] = mission.name,
                ['@level'] = missionMaxLevel,
                ['@exp'] = 0,
            })

            return 0 -- 미션 경험치가 없을 경우, 초기값인 0XP를 반환합니다.
        else
            OxMySQL:executeSync("INSERT INTO mission (id, mission, level, exp) VALUES (@id, @mission, @level, @exp)", {
                ['@id'] = citizenId,
                ['@mission'] = mission.name,
                ['@level'] = 1,
                ['@exp'] = mission.levels[1].minEXP,
            })

            return mission.levels[1].minEXP -- 미션 경험치가 없을 경우, 초기값인 최소 경험치를 반환합니다.
        end
    else
        local currentEXP = result[1].exp
        return currentEXP
    end
end

SetLevel = function (source, mission, value)
    local citizenId = exports['service.base_framework']:GetCitizenId(source)

    local currentLevel, currentEXP = GetLevel(source, mission), GetEXP(source, mission); if currentLevel == nil or currentEXP == nil then
        return
    end

    local missionMaxLevel = GetMaxLevel(mission.levels)

    if value <= missionMaxLevel and missionMaxLevel ~= 0 then
        OxMySQL:execute("UPDATE mission SET level = @level WHERE id = @id AND mission = @mission", {
            ['@id'] = citizenId,
            ['@mission'] = mission.name,
            ['@level'] = value
        })

        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = string.format('%s레벨에 달성하였습니다!<br>- 현재 경험치: (%s/%sXP)', currentLevel + 1, FormatComma(currentEXP), FormatComma(mission.levels[currentLevel + 1].maxEXP))
        })
    else
        if missionMaxLevel ~= 0 then
            TriggerClientEvent('client/main/notify:SendMessage', source, {
                message = '최대 레벨에 도달하여 더 이상 레벨업이 진행되지 않습니다!<br>다른 미션을 수행해 보시는 건 어떨까요?'
            })
        end
    end
end

SetEXP = function (source, mission, value)
    local citizenId = exports['service.base_framework']:GetCitizenId(source)

    local currentLevel, currentEXP = GetLevel(source, mission), GetEXP(source, mission); if currentLevel == nil or currentEXP == nil then
        return
    end

    local missionMaxLevel = GetMaxLevel(mission.levels)

    local newEXP = currentEXP + value

    OxMySQL:execute("UPDATE mission SET exp = @exp WHERE id = @id AND mission = @mission", {
        ['@id'] = citizenId,
        ['@mission'] = mission.name,
        ['@exp'] = currentEXP + value
    })

    local nextLevelRequiredEXP = mission.levels[currentLevel].maxEXP - newEXP

    if currentLevel == missionMaxLevel  then
        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = string.format('경험치 %sXP를 획득하였습니다!<br>- 다음 레벨까지 남은 경험치: ∞ XP (MAX)', value)
        })
    elseif nextLevelRequiredEXP < 0 then
        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = string.format('경험치 %sXP를 획득하였습니다!<br>- 다음 레벨까지 남은 경험치: %sXP', FormatComma(value), FormatComma(mission.levels[currentLevel + 1].maxEXP - newEXP))
        })
    else
        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = string.format('경험치 %sXP를 획득하였습니다!<br>- 다음 레벨까지 남은 경험치: %sXP', FormatComma(value), FormatComma(nextLevelRequiredEXP))
        })
    end

    if newEXP > mission.levels[currentLevel].maxEXP and currentLevel + 1 <= missionMaxLevel and missionMaxLevel ~= 0 then
        SetLevel(source, mission, currentLevel + 1)
    end
end

---

StartMission = function (source, mission, missionLevel)
    TriggerClientEvent('client/main/mission:StartMission', source, mission, missionLevel)
end

RegisterNetEvent('server/main/mission:StartMission', function (source, mission, missionLevel)
    StartMission(source, mission, missionLevel)
end)

StopMission = function (source)
    TriggerClientEvent('client/main/mission:StopMission', source)
end

RegisterNetEvent('server/main/mission:StopMission', function (source)
    StopMission(source)
end)

UpdateMission = function (source)
    StopMission(source) -- 업데이트 전, 현재 진행 중인 미션을 취소합니다.

    for _, mission in ipairs(CONFIG_MISSIONS) do
        local IS_PLAYER_MISSION_ENABLED = false

        if mission.permission[1] == 'JOB' then
            if exports['service.base_framework']:GetJobName(source) == mission.permission[2] then
                IS_PLAYER_MISSION_ENABLED = true
            end
        elseif mission.permission[1] == 'COMPANY' then
            if exports['service.base_framework']:GetCompany(source) == mission.permission[2] then
                IS_PLAYER_MISSION_ENABLED = true
            end
        elseif mission.permission[1] == 'PERMISSION' then
            if exports['service.base_framework']:HasPermission(source, mission.permission[2]) then
                IS_PLAYER_MISSION_ENABLED = true
            end
        end

        if IS_PLAYER_MISSION_ENABLED then
            StartMission(source, mission, GetLevel(source, mission))
        else
            TriggerClientEvent('client/main/notify:SendMessage', source, {
                message = '현재 미션을 수행할 수 있는 직업을 가지고 있지 않습니다.<br>시청에서 직업을 바꾸거나 시민직업 이용권을 구매 후 사용하세요.'
            })
        end
    end
end

RegisterNetEvent('server/main/mission:UpdateMission', function (source)
    UpdateMission(source)
end)

CompleteMission = function (source, mission, products); products = json.decode(products)
    local missionLevel, missionEXP = GetLevel(source, mission), GetEXP(source, mission); if missionLevel == nil or missionEXP == nil then
        return
    end

    local missionMaxLevel = GetMaxLevel(mission.levels)

    -- 미션 대상품목 소유 여부를 확인합니다.
    local hasMissionProducts = true

    for _, product in ipairs(products) do
        local hasItem = exports['service.main_inventory']:HasItem(source, product.item, product.amount)

        if not hasItem then
            hasMissionProducts = false
            break
        end
    end

    -- 미션 완료 보상을 지급합니다.
    if not hasMissionProducts then
        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = '미션 대상품목이 부족하여 미션을 완료할 수 없습니다!'
        })
        return
    else
        StopMission(source) -- 미션 완료처리 전, 버그 악용을 방지하기 위해 현재 진행 중인 미션을 취소합니다.

        for _, product in ipairs(products) do
            local productPrice = product.price * product.amount

            exports['service.base_framework']:AddCash(source, productPrice)
            TriggerEvent('server/main/inventory:RemoveItem', source, product.item, product.amount) -- 미션 대상품목을 모두 소유하고 있다면, 순서대로 인벤토리에서 제거합니다.

            TriggerClientEvent('client/main/notify:SendMessage', source, {
                message = string.format('[+] %s (%s개) - %s원', product.name, product.amount, FormatComma(productPrice))
            })
        end
    end

    -- 미션 완료 추가 보상을 지급합니다.
    for _, reward in ipairs(mission.rewards[missionLevel]) do
        if reward.value == 'money_cash' then
            exports['service.base_framework']:AddCash(source, reward.amount)
            TriggerClientEvent('client/main/notify:SendMessage', source, {
                message = string.format('[+] %s', reward.name)
            })
        else
            TriggerEvent('server/main/inventory:AddItem', source, reward.value, reward.amount)
            TriggerClientEvent('client/main/notify:SendMessage', source, {
                message = string.format('[+] %s (%s개)', reward.name, reward.amount)
            })
        end
    end

    -- 미션 레벨/경험치를 지급합니다.
    if missionMaxLevel > 0 then
        local rewardEXP = math.random(100, 200)
        SetEXP(source, mission, rewardEXP)
    else
        TriggerClientEvent('client/main/notify:SendMessage', source, {
            message = '특수 미션은 경험치가 지급되지 않습니다.'
        })
    end

    TriggerClientEvent('client/main/notify:SendMessage', source, {
        message = '미션을 성공적으로 완료하였습니다!'
    })

    SetTimeout(mission.options.nextMissionDelay, function ()
        UpdateMission(source)
    end)
end

RegisterNetEvent('server/main/mission:CompleteMission', function (mission, products)
    local source = source
    CompleteMission(source, mission, products)
end)

RegisterCommand('미션', function (source)
    UpdateMission(source)
end, false)

RegisterCommand('미션종료', function (source)
    StopMission(source)
end, false)