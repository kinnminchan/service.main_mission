--[[
     __  __     __  __     ______     ______    
    /\ \_\ \   /\ \_\ \   /\  == \   /\  ___\   
    \ \  __ \  \ \____ \  \ \  __<   \ \  __\   
     \ \_\ \_\  \/\_____\  \ \_____\  \ \_____\ 
      \/_/\/_/   \/_____/   \/_____/   \/_____/ 
     ______     __  __    
    /\  == \   /\ \_\ \   
    \ \  __<   \ \____ \  
     \ \_____\  \/\_____\ 
      \/_____/   \/_____/ 
     __    __     __     __   __     ______     __  __     ______     __   __    
    /\ "-./  \   /\ \   /\ "-.\ \   /\  ___\   /\ \_\ \   /\  __ \   /\ "-.\ \   
    \ \ \-./\ \  \ \ \  \ \ \-.  \  \ \ \____  \ \  __ \  \ \  __ \  \ \ \-.  \  
     \ \_\ \ \_\  \ \_\  \ \_\\"\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \_\\"\_\ 
      \/_/  \/_/   \/_/   \/_/ \/_/   \/_____/  \/_/\/_/   \/_/\/_/   \/_/ \/_/ 


    HYBE BY MINCHAN

    IF YOU'RE INTERESTED IN USING THIS RESOURCE, FEEL FREE TO CONTACT ME ON DISCORD: @youjustnod.
]]--

fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    'data/config/*.lua'
}

client_scripts {
    'src/client.lua'
}

server_scripts {
    'src/server.lua'
}

ui_page 'web/build/index.html'

files {
    'web/**'
}