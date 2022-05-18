local menu, PlayerData = {}, {}
local isDead, disabled = false, false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	removeMenu(Config.JobOption.label)
    Wait(100)
    AddJobMenu()
end)

Citizen.CreateThread(function()
    for i=1, #Config.RadialMenu do
        menu[#menu + 1] = Config.RadialMenu[i]
    end
    AddJobMenu()
end)

RegisterNUICallback('initialize', function(data, cb)
    cb({
        size = Config.UI.Size,
        colors = Config.UI.Colors
    })
end)

RegisterNUICallback('hideFrame', function(data,cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('clickedItem', function(data, cb)
    SetNuiFocus(false, false)
    if not data.args then
        data.args = {}
    end
    if data.client then
        TriggerEvent(data.event, table.unpack(data.args))
    elseif not data.client then
        TriggerServerEvent(data.event, table.unpack(data.args))
    end
    cb('ok')
end)

function addMenu(data)
    if data.label and data.icon and (data.submenu or (data.client ~= nil and data.shouldClose ~= nil and data.event)) then
        menu[#menu + 1] = data
    end
end

exports('addMenu', addMenu)

function removeMenu(label)
    if label then
        removeItemFromArray(menu, 'label', label)
    end
end

exports('removeMenu', removeMenu)

exports('setDead', function(status)
    isDead = status
end)

exports('disable', function(toggle)
    disabled = toggle
end)

function AddJobMenu()
    if ESX.PlayerData.job and Config.JobMenu[ESX.PlayerData.job.name] then
        local joboption = {
            label = Config.JobOption.label,
            icon = Config.JobOption.icon,
            submenu = {}
        }

        for i=1, #Config.JobMenu[ESX.PlayerData.job.name] do
            joboption.submenu[#joboption.submenu + 1] = Config.JobMenu[ESX.PlayerData.job.name][i]
        end
        menu[#menu + 1] = joboption
    end
end

RegisterCommand(Config.Open.command, function()
    if not disabled then
        SetNuiFocus(true, true)
        if isDead then
            SendNUIMessage({
                action="openMenu",
                data=Config.DeadMenu
            })
        else
            SendNUIMessage({
                action="openMenu",
                data=menu
            })
        end
    end
end)

if not Config.Open.commandonly then
    RegisterKeyMapping(Config.Open.command, 'Open Radial Menu', 'keyboard', Config.Open.key)
end

-- Utils
function removeItemFromArray(array, property, value)
    for i=1, #array do
        if array[i][property] == value then
            array[i] = nil
            break
        end
    end
end
