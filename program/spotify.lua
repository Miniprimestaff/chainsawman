local basalt = require("basalt")
local aukit = require("aukit")
local austream = shell.resolveProgram("austream")

-- Téléchargement du fichier de la liste de lecture
local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  -- Parsing du fichier JSON de la liste de lecture
  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(playlist) == "table" then
    -- Création de la liste sélectionnable des musiques
    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry.title)
    end

    -- Création de la liste scrollable
    local scrollableList = basalt.createScrollableFrame()
    scrollableList:setTitle("Liste des musiques")

    -- Ajout des musiques à la liste scrollable
    for index, music in ipairs(musicList) do
      local button = scrollableList:addButton():setText(music)

      button:onClick(function(self, event, button, x, y)
        if (event == "mouse_click") and (button == 1) then
          local selectedMusic = playlist[index]
          local selectedTitle = selectedMusic.title
          local selectedURL = selectedMusic.link

          -- Mise à jour du titre de la musique en cours
          currentMusicTitle = selectedTitle
          print("Lecture de la musique : " .. currentMusicTitle)

          -- Lecture de la musique sélectionnée
          shell.run(austream, selectedURL)

          -- Attente jusqu'à la fin de la musique ou interruption de l'utilisateur
          while true do
            if not isPaused then
              local status, result = pcall(aukit.isPlaying)
              if not status or not result then
                break
              end
            end
            sleep(1)
          end
        end
      end)
    end

    term.clear()
    scrollableList:draw()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
