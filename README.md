# HYBE DROPPED PROJECT RESOURCE - MISSION

해당 리소스는 과거 HYBE 서버 운영 시 사용되었던 시스템입니다.

### 리소스 특징
> - 배달 미션 (퍼미션, 직업)
> - 배달 미션 경험치-레벨 시스템
> - 배달 미션 위치 빌립스, 경로 자동 설정 (지도 GPS X)

(+) CONFIG 설정을 통해 여러 미션을 설정할 수 있습니다. (데이터 개별 저장)

### 리소스 수정 필요에 대한 안내

리뉴얼된 HYBE 서버는 자체 개발한 프레임워크 기반으로 운영되었기 때문에, vRP, ESX, QBCore, OxCore와 같은 외부 시스템을 사용하지 않았습니다. 따라서, 리소스를 적용하려는 서버 환경에 맞게 일부 수정이 필요합니다.

#### 1. `src/server.lua`

```lua
-- line ...
local citizenId = exports['service.base_framework']:GetCitizenId(source)
```

해당 부분을 "서버의 플레이어 ID (고유번호) GETTER 로직"에 맞게 변경해 주세요. (**여러 군데 위치해 있습니다.**)

```lua
-- line ...
TriggerClientEvent('client/main/notify:SendMessage', source, { message = '~~' })
```

해당 부분을 "서버의 NOTIFY 로직"에 맞게 변경해 주세요. (**여러 군데 위치해 있습니다.**)

```lua
--- line 192~
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
```

해당 부분을 "서버의 플레이어 직업 / 회사 / 퍼미션 GETTER 로직"에 맞게 변경해 주세요.

```lua
-- line 231
local hasItem = exports['service.main_inventory']:HasItem(source, product.item, product.amount)
```

해당 부분을 "서버의 플레이어 아이템 보유량 확인 로직"에 맞게 변경해 주세요.

```lua
-- line ...
exports['service.base_framework']:AddCash(source, price)
```

해당 부분을 "서버의 플레이어 현금 지급 로직"에 맞게 변경해 주세요. (**여러 군데 위치해 있습니다.**)

```lua
-- line ...
TriggerEvent('server/main/inventory:AddItem', source, item, amount)
TriggerEvent('server/main/inventory:RemoveItem', item, amount)
```

해당 부분을 "서버의 플레이어 아이템 지급/회수 로직"에 맞게 변경해 주세요. (**여러 군데 위치해 있습니다.**)

### 참고사항
- OxMysql 또는 기타 MySQL 시스템이 필요합니다.
- 리소스에 문제가 있거나 도움이 필요하신 경우, kinnminchan@gmail.com 또는 디스코드 @youjustnod로 언제든지 문의 주세요.