local aukit = require("aukit")
local austream = shell.resolveProgram("austream")
local term = require("term")

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
      table.insert(musicList, entry)
    end

    -- Fonction pour lire une musique
    local function playMusic(title, musicURL)
      -- Lecture de la musique en utilisant AUStream
      shell.run(austream, musicURL)
      
      -- Affichage du titre de la musique en cours de lecture
      print("Lecture de la musique : " .. title)
      
      -- Attente jusqu'à la fin de la musique
      while aukit.isPlaying() do
        sleep(1)
      end
    end

    -- Variables de contrôle
    local selectedPosition = 1

    -- Variables pour le défilement de la liste
    local maxLines = 10 -- Nombre maximal de lignes à afficher
    local startIndex = 1 -- Indice de départ pour afficher les musiques
    local endIndex = math.min(#musicList, startIndex + maxLines - 1) -- Indice de fin pour afficher les musiques

    -- Gestion de l'événement de défilement de la souris
    local function handleScrollEvent(direction)
      if direction == -1 and selectedPosition > 1 then
        selectedPosition = selectedPosition - 1
        if startIndex > 1 then
          startIndex = startIndex - 1
          endIndex = endIndex - 1
          term.scroll(1) -- Défilement d'une ligne vers le haut
        end
      elseif direction == 1 and selectedPosition < maxLines and startIndex + selectedPosition <= #musicList then
        selectedPosition = selectedPosition + 1
        if endIndex < #musicList then
          startIndex = startIndex + 1
          endIndex = endIndex + 1
          term.scroll(-1) -- Défilement d'une ligne vers le bas
        end
      end
    end

    -- Affichage initial de la liste des musiques
    term.clear()
    for i = startIndex, endIndex do
      local music = musicList[i]
      print(i .. ". " .. music.title)
    end

    while true do
      -- Attente d'un événement de défilement de la souris
      local _, scrollDirection = os.pullEvent("mouse_scroll")
      handleScrollEvent(scrollDirection)

      -- Sélection de la musique et lecture
      local selectedMusicIndex = startIndex + selectedPosition - 1
      if selectedMusicIndex >= 1 and selectedMusicIndex <= #musicList then
        local selectedMusic = musicList[selectedMusicIndex]
        local selectedTitle = selectedMusic.title
        local selectedURL = selectedMusic.link
        -- Lecture de la musique sélectionnée
        playMusic(selectedTitle, selectedURL)
      end

      -- Affichage mis à jour de la liste des musiques
      term.clear()
      for i = startIndex, endIndex do
        local music = musicList[i]
        print(i .. ". " .. music.title)
      end
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
