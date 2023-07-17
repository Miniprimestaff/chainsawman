local aukit = require("aukit")
local austream = shell.resolveProgram("austream")
local basalt = require("basalt")

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

    -- Création de la fenêtre de l'interface utilisateur
    local main = basalt.createFrame()

    -- Création de la liste défilable des musiques
    local musicListFrame = main:addScrollableFrame():setPosition(1, 1):setSize(30, 10)
    for i, title in ipairs(musicList) do
      musicListFrame:addButton(title):setOnClick(function()
        local selectedMusic = playlist[i]
        local selectedTitle = selectedMusic.title
        local selectedURL = selectedMusic.link

        -- Affichage du titre de la musique en cours de lecture
        main:clear()
        print("Lecture de la musique : " .. selectedTitle)

        -- Lecture de la musique en utilisant AUStream
        shell.run(austream, selectedURL)

        -- Attente jusqu'à la fin de la musique
        while true do
          local status, result = pcall(aukit.isPlaying)
          if not status or not result then
            break
          end
          sleep(1)
        end

        -- Affichage de la liste des musiques après la fin de la lecture
        main:clear()
      end)
    end

    -- Affichage initial de la liste des musiques
    main:draw()

    -- Boucle principale pour gérer les événements utilisateur
    while true do
      local event, key = os.pullEvent("key")
      if event == "key" and key == keys.q then
        -- Interruption de l'utilisateur
        break
      end
      main:onEvent(event, key)
      main:draw()
    end
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
