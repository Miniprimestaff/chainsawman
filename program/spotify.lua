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

    -- Fonction pour lire une musique
    local function playMusic(title, musicURL)
      -- Lecture de la musique en utilisant AUStream
      shell.run(austream, musicURL)
      
      -- Affichage du titre de la musique en cours de lecture
      print("Lecture de la musique : " .. title)
      
      -- Attente jusqu'à la fin de la musique
      while true do
        local status, result = pcall(aukit.isPlaying)
        if not status or not result then
          break
        end
        sleep(1)
      end
    end

    -- Variables pour le défilement de la liste
    local maxLines = 10 -- Nombre maximal de lignes à afficher
    local startIndex = 1 -- Indice de départ pour afficher les musiques
    local endIndex = math.min(#musicList, startIndex + maxLines - 1) -- Indice de fin pour afficher les musiques

    -- Gestion de l'événement de défilement de la souris
    local function handleScrollEvent(direction)
      if direction == -1 and startIndex > 1 then
        startIndex = startIndex - 1
        endIndex = endIndex - 1
        term.scroll(1) -- Défilement d'une ligne vers le haut
      elseif direction == 1 and endIndex < #musicList then
        startIndex = startIndex + 1
        endIndex = endIndex + 1
        term.scroll(-1) -- Défilement d'une ligne vers le bas
      end
    end

    -- Fonction pour afficher la liste des musiques
    local function drawMusicList()
      term.clear()
      for i = startIndex, endIndex do
        print(i .. ". " .. musicList[i])
      end
    end

    -- Affichage initial de la liste des musiques
    drawMusicList()

    while true do
      local event, param = os.pullEvent()
      if event == "key" then
        if param == keys.up then
          handleScrollEvent(-1)
          drawMusicList()
        elseif param == keys.down then
          handleScrollEvent(1)
          drawMusicList()
        elseif param == keys.enter then
          local selectedMusicIndex = startIndex + (h - 1) - term.getCursorY()
          if selectedMusicIndex >= startIndex and selectedMusicIndex <= endIndex then
            local selectedMusic = playlist[selectedMusicIndex]
            local selectedTitle = selectedMusic.title
            local selectedURL = selectedMusic.url
            -- Lecture de la musique sélectionnée
            playMusic(selectedTitle, selectedURL)
          end
        end
      end
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
