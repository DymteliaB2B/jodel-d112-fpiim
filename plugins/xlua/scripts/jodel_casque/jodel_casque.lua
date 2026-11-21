-- Casque anti-bruit du Jodel D112 F-PIIM (case du calepin, dataref lf71dc/jodel/casque).
-- Dans le cockpit, casque coche : le volume "Exterieur" de X-Plane (moteur, helice, vent) est attenue,
-- d'autant plus que le bouton VOL de l'interphone est tourne (lf71dc/jodel/casque_niveau, 0 a 1).
-- En vue exterieure, casque retire ou avion decharge, l'utilisateur retrouve son propre reglage.
-- Genere par son_fpiim.py.

REDUCTION_MAX = 0.90      -- part du volume exterieur retiree bouton VOL au maximum
NIVEAU_DEFAUT = 0.75      -- position du bouton au chargement (volume garde : 1 - 0,9 x 0,75 = 33 %)
RAMP = 2.0                -- vitesse du fondu (gain par seconde)

casque = create_dataref("lf71dc/jodel/casque", "number", function() end)
niveau = create_dataref("lf71dc/jodel/casque_niveau", "number", function() end)
ext_vol = find_dataref("sim/operation/sound/exterior_volume_ratio")
view_ext = find_dataref("sim/graphics/view/view_is_external")

local base = nil          -- reglage "Exterieur" de l'utilisateur
local gain = 1.0          -- facteur applique par le casque
local written = nil       -- derniere valeur ecrite par ce script

function aircraft_load()
    niveau = NIVEAU_DEFAUT
    base = ext_vol
    gain = 1.0
    written = nil
end

function after_physics()
    if base == nil then base = ext_vol end
    -- reglage modifie par l'utilisateur dans les options : nouvelle reference
    if written ~= nil and math.abs(ext_vol - written) > 0.002 then
        base = ext_vol
        gain = 1.0
    end
    local target = 1.0
    if casque > 0.5 and view_ext < 0.5 then
        target = 1.0 - REDUCTION_MAX * math.max(0.0, math.min(1.0, niveau))
    end
    local dt = SIM_PERIOD or 0.05
    if dt <= 0 or dt > 0.5 then dt = 0.05 end
    if gain < target then gain = math.min(target, gain + RAMP * dt)
    elseif gain > target then gain = math.max(target, gain - RAMP * dt) end
    local v = base * gain
    if written == nil or math.abs(v - written) > 0.0005 then
        ext_vol = v
        written = v
    end
end

function aircraft_unload()
    if base ~= nil then ext_vol = base end
end
